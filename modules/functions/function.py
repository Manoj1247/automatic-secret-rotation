import os
import boto3
import json
import random
import string
from datetime import datetime, timedelta

secrets_client = boto3.client('secretsmanager')

# Retrieve the secret_id from environment variables
secret_id = os.getenv('secret_id')

# Check if the secret_id is set
if secret_id is None:
    raise ValueError('SECRET_ID environment variable is not set')


def lambda_handler(event, context):
    try:
        
        # Get secret metadata
        secret_metadata = get_secret_metadata(secret_id)
        no_of_days_until_next_rotation = secret_metadata.get('AutomaticallyAfterDays')
        current_date = datetime.now()
        next_rotation_date = current_date + timedelta(days=no_of_days_until_next_rotation)
        
        # Get secret values
        secret_value_response = secrets_client.get_secret_value(SecretId=secret_id)
        secret_string = secret_value_response['SecretString']
        secret_data = json.loads(secret_string)
        
        print(f'Secret Metadata: {json.dumps(secret_metadata)}')
        
        keys = secret_data.keys()
        
        for key in keys:
            # Generate a new key when the next rotation is in 10 days
            if no_of_days_until_next_rotation <= 10:
                new_value = ''.join(random.choices(string.ascii_letters + string.digits, k=16))
                current_value = secret_data[key]
                current_values = secret_data.get(key, '').split(',') 
                #print('CV' , current_values)
              
                if len(current_values) > 1:
                    current_values[0] = current_values[1]
                    current_values[1] = new_value
                    updated_value = ", ".join(current_values)
                elif len(current_values) == 1 and current_value:
                    updated_value = f'{current_value}, {new_value}'
                else :
                    updated_value = new_value

                secret_data[key] = updated_value 
                
                secrets_client.put_secret_value(
                    SecretId=secret_id,
                    SecretString=json.dumps(secret_data)
                )
                
            # Remove old value part when rotation has expired
            if current_date == next_rotation_date or no_of_days_until_next_rotation <= 1:
                values = secret_data.get(key, '').split(',')
                if len(values) > 1:
                    secret_data[key] = values[-1]
                     
                    secrets_client.put_secret_value(
                        SecretId=secret_id,
                        SecretString=json.dumps(secret_data)
                    )
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Secret metadata retrieved successfully',
                'AutomaticallyAfterDays': no_of_days_until_next_rotation
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error retrieving or updating secret: {str(e)}')
        }

def get_secret_metadata(secret_id):
    response = secrets_client.describe_secret(
        SecretId=secret_id
    )
    return response['RotationRules']
