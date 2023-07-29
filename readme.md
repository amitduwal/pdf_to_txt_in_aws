# PDF to Text Conversion Lambda

This project sets up an AWS Lambda function that converts PDF files stored in an S3 bucket into text files and saves them to another S3 bucket. The Lambda function uses the PyMuPDF library for fast PDF processing. Additionally, it includes a Lambda layer containing the necessary PyMuPDF dependencies.

## Overview

The main components of the project are as follows:

1. **AWS IAM Policies and Role**: IAM policies define the necessary permissions for the Lambda function to interact with S3 buckets. A role is created and attached to the Lambda function, allowing it to assume the required permissions.

2. **Lambda Function Source Code**: The Lambda function's Python source code is provided in a ZIP archive. It contains the necessary logic to convert PDF files to text.

3. **Lambda Layer**: A Lambda layer is included, containing the PyMuPDF library and its dependencies. This layer is associated with the Lambda function to facilitate PDF processing.

4. **S3 Buckets**: Two S3 buckets are created—one for storing PDF files and another for storing the converted text files.

5. **S3 Bucket Notification**: A bucket notification configuration is set up to trigger the Lambda function when new PDF files are uploaded to the PDF bucket.

6. **CloudWatch Log Group**: A CloudWatch Log Group is established to store the Lambda function's logs.

## Setup Instructions

Follow these steps to set up the project:

1. Create an AWS IAM role with the necessary permissions for the Lambda function. The IAM policy allows the Lambda function to read from the PDF bucket and write to the text bucket.

2. Package the Lambda function's source code and dependencies into a ZIP archive. The code handles the PDF to text conversion.

3. Create a Lambda layer ZIP archive containing the PyMuPDF library and its dependencies.

4. Create two S3 buckets—one for storing PDF files and another for storing text files.

5. Configure the S3 bucket notification to trigger the Lambda function when new PDF files are uploaded to the PDF bucket.

6. Deploy the Lambda function using the IAM role and Lambda layer created earlier.

7. Verify that the Lambda function works correctly by uploading PDF files to the PDF bucket and checking for corresponding text files in the text bucket.

## Files and Directories

- **src**: Contains the Lambda function's source code.

- **pymupdf_for_fast.zip**: The Lambda layer ZIP archive containing the PyMuPDF library and its dependencies.

- **my-deployment.zip**: The ZIP archive containing the Lambda function's source code and dependencies.

- **terraform.tf**: Terraform configuration file for creating AWS resources.

- **README.md**: This readme file.

## Deployment

1. Ensure you have Terraform installed on your local machine.

2. Modify the Terraform configuration (terraform.tf) if necessary, such as region, bucket names, or other configurations.

3. Run `terraform init` to initialize the Terraform configuration.

4. Run `terraform apply` to create the AWS resources.

5. Upload PDF files to the PDF bucket (amit-s3-pdf-bucket) to trigger the Lambda function and convert the PDFs to text.

6. Check the text bucket (amit-s3-txt-bucket) for the converted text files.

7. Monitor the Lambda function's logs in the CloudWatch Log Group (/aws/lambda/pdf_txt_generation_lambda).

## Cleanup

To clean up and remove all AWS resources created by this project, run `terraform destroy`.

Please note that the project assumes you have the necessary AWS credentials and permissions to create and manage resources in your AWS account.

Feel free to explore the source code and Terraform configurations to customize the project based on your specific requirements.

Happy PDF to Text Conversion!