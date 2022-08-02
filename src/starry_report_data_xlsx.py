import boto3
import os
import io
import logging
import pandas as pd
logger = logging.getLogger()
logger.setLevel(logging.INFO)
client = boto3.client('redshift-data')
s3 = boto3.resource('s3')
def handler(event, context):
    try:
        # s3_bucket = os.environ['BUCKET']
        # s3_key = os.environ['KEY']
        report_data = get_s3_object('omni-report-email', 'csv-report-starry/report.csv000')
        buffer = io.BytesIO()
        with pd.ExcelWriter(buffer) as writer:
                report_data.to_excel(writer,index=False)
        data = buffer.getvalue()
        s3.Bucket('omni-report-email').put_object(Key='csv-report-starry/report.xlsx', Body=data)
    except Exception as e:
        logging.exception("ConvertCSVToXLSXError: {}".format(e))

def get_s3_object(bucket, key):
    try:
        client = boto3.client('s3')
        response = client.get_object(Bucket=bucket, Key=key)
        data = pd.read_csv(io.BytesIO(response['Body'].read()), dtype=str)
        print(data)
        return data
    except Exception as e:
        logging.exception("S3GetObjectError: {}".format(e))
