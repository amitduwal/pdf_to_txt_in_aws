variable "s3_bucket_names" {
  type = list
  default = ["amit_s3_pdf_bucket", "amit_s3_txt_bucket"]
}

variable "aws_region" {
    type = string
    default = "ap-south-1"
  
}