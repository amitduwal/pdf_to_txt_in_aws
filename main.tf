resource "aws_iam_policy" "pdf_txt_s3_policy" {
  policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [{
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::amit-s3-pdf-bucket/*"
        }, {
            "Effect": "Allow",
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::amit-s3-txt-bucket/*"
        }]
    })
}

resource "aws_iam_role" "pdf_txt_lambda_role" {
    name = "pdf_txt_lambda_role"
    assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [{
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }]
    }) 
}

resource "aws_iam_policy_attachment" "pdf_txt_role_s3_policy_attachment" {
    name = "pdf_txt_role_s3_policy_attachment"
    roles = [ aws_iam_role.pdf_txt_lambda_role.name ]
    policy_arn = aws_iam_policy.pdf_txt_s3_policy.arn
}

resource "aws_iam_policy_attachment" "pdf_txt_role_lambda_policy_attachment" {
    name = "pdf_txt_role_lambda_policy_attachment"
    roles = [ aws_iam_role.pdf_txt_lambda_role.name ]
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "pdf_txt_lambda_source_archive" {
  type = "zip"

  source_dir  = "${path.module}/src"
  output_path = "${path.module}/my-deployment.zip"
}

resource "aws_lambda_layer_version" "pdf_txt_lambda_layer" {
  filename   = "pymupdf_for_fast.zip"
  layer_name = "pdf_txt_lambda_layer"

  compatible_runtimes = ["python3.7"]
}

resource "aws_lambda_function" "pdf_txt_lambda" {
    function_name = "pdf_txt_generation_lambda"
    filename = "${path.module}/my-deployment.zip"

    runtime = "python3.7"
    handler = "lambda_function.lambda_handler"
    memory_size = 1024

    source_code_hash = data.archive_file.pdf_txt_lambda_source_archive.output_base64sha256

    role = aws_iam_role.pdf_txt_lambda_role.arn

    layers = [
        aws_lambda_layer_version.pdf_txt_lambda_layer.arn
    ]
    timeout = 800
}

resource "aws_s3_bucket" "amit_s3_pdf_bucket" {
  bucket = "amit-s3-pdf-bucket"
}

resource "aws_s3_bucket" "amit_s3_txt_bucket" {
  bucket = "amit-s3-txt-bucket"
}

resource "aws_lambda_permission" "pdf_txt_allow_bucket" {
  statement_id = "AllowExecutionFromS3Bucket"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pdf_txt_lambda.arn
  principal = "s3.amazonaws.com"
  source_arn = aws_s3_bucket.amit_s3_pdf_bucket.arn
}

resource "aws_s3_bucket_notification" "pdf_txt_notification" {
    bucket = aws_s3_bucket.amit_s3_pdf_bucket.id

    lambda_function {
        lambda_function_arn = aws_lambda_function.pdf_txt_lambda.arn
        events = [ "s3:ObjectCreated:*" ]
    }

    depends_on = [
      aws_lambda_permission.pdf_txt_allow_bucket
    ]
}

resource "aws_cloudwatch_log_group" "pdf_txt_cloudwatch" {
  name = "/aws/lambda/${aws_lambda_function.pdf_txt_lambda.function_name}"

  retention_in_days = 30
}