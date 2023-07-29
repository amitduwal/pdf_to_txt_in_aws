

import os
import boto3
import fitz  # PyMuPDF
from io import BytesIO

def pdf_to_text(input_pdf_object, output_text_bucket, output_text_key):
    # PyMuPDF's Document expects a file-like object or a file path as input to read the PDF file. 
    # By using BytesIO, we create a file-like object from the binary data, making it compatible with PyMuPDF's interface.
    pdf_bytes = input_pdf_object['Body'].read()
    pdf_stream = BytesIO(pdf_bytes)

    pdf_document = fitz.open(stream=pdf_stream, filetype="pdf")

    text = ""
    for page_num in range(pdf_document.page_count):
        page = pdf_document.load_page(page_num)
        text += page.get_text()

    # Store the text in txt file in the required bucket 
    s3_client = boto3.client('s3')
    s3_client.put_object(Bucket=output_text_bucket, Key=output_text_key, Body=text, ContentType='text/plain')

def lambda_handler(event, context):
    # Get the source bucket and key (PDF file uploaded)
    source_bucket = event['Records'][0]['s3']['bucket']['name']   
    source_key = event['Records'][0]['s3']['object']['key']

    # Check if the file is a PDF before proceeding
    if not source_key.lower().endswith('.pdf'):
        return {
            'statusCode': 400,
            'body': 'Not a PDF file. Ignoring.'
        }
    
    # Specify the destination bucket and key (text file to be stored)
    destination_bucket = "amit-s3-txt-bucket" 
    destination_key = os.path.splitext(source_key)[0] + ".txt"  # Same filename with .txt extension

    # Get the PDF object from the source bucket
    s3_client = boto3.client('s3')
    pdf_object = s3_client.get_object(Bucket=source_bucket, Key=source_key)

    # Convert PDF to text and store it in the destination bucket
    pdf_to_text(pdf_object, destination_bucket, destination_key)

    return {
        'statusCode': 200,
        'body': 'PDF to text conversion complete.'
    }

