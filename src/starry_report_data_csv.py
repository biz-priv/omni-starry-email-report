import boto3
import os
import logging
client = boto3.client('redshift-data')
s3_client = boto3.client('s3')
def handler(event, context):

        try:
                response = s3_client.get_object(Bucket='omni-report-email',Key='scripts/report-email-starry.sql')
                
        except Exception as e:
                logging.exception("GetObjectError: {}".format(e))
        
        try:
                obj = response['Body'].read()
                obj = (obj.decode('utf-8'))
        except Exception as e:
                logging.exception("DiffSQLScriptReadError: {}".format(e))    
        
        try:
                client.execute_statement(Database=os.environ['DBNAME'], DbUser=os.environ['USER'], Sql=obj, ClusterIdentifier=os.environ['CLUSTERID'])
                
        except Exception as e:
                logging.exception("DiffQueryExecutionError: {}".format(e))
                