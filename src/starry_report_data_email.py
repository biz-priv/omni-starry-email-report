import boto3
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.application import MIMEApplication
import smtplib
import datetime
import os

def handler(event, context):
    sender = 'reports@omnilogistics.com'
    receiver = ['acuartas@starry.com','lspencer@starry.com','lpietraszek@starry.com','ausops@omnilogistics.com','jkavuluri@bizcloudexperts.com','asalaices@omnilogistics.com','kiranv@bizcloudexperts.com']
    msg = MIMEMultipart()
    today_date =  str(datetime.date.today())
    msg['Subject'] = '{} {}'.format('Starry Report |', today_date)
    msg['From'] = 'reports@omnilogistics.com'
    msg['To'] = 'acuartas@starry.com,lspencer@starry.com,lpietraszek@starry.com,ausops@omnilogistics.com'
    s3 = boto3.client("s3")
    fileObj = s3.get_object(Bucket = 'omni-report-email', Key = 'csv-report-starry/report.xlsx')
    file_content = fileObj["Body"].read()
    attachment = MIMEApplication(file_content)
    attachment.add_header("Content-Disposition", "attachment", filename="report.xlsx")
    msg.attach(attachment)
    smtp_server = smtplib.SMTP("email-smtp.us-east-1.amazonaws.com")
    smtp_server.starttls()
    smtp_server.login(os.environ['USER'], os.environ['PASS'])
    smtp_server.sendmail(sender, receiver, msg.as_string())
