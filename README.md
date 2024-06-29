# automatic-secret-rotation
## Overview
1. This project automates the rotation of secrets stored in AWS Secrets Manager using an AWS Lambda function.
2. Secrets are rotated in a way that the old secret value is stored for 10 days before it gets deleted from the Secret Manager. 
3. For instance, let's suppose that we have a secret key  that is getting rotated in less than 10 days.<br>
    - Before adding the new value :
        - key : splunk
        - value : "dsadasfdfd" <br>
    - After adding the new value :
        - key : splunk
        - value : "dsadasfdfd, gfdgdreerw"
4. After the rotation day, the old value will be removed and the new one will be retained.<br>
        
    - key : splunk
    - value : "gfdgdreerw"
5. The lambda function is automatically triggered on the rotation day by the secret manager.

6. The Lambda function is also triggered every 10 days by an Amazon EventBridge (formerly CloudWatch Events) rule. The infrastructure is provisioned using Terraform.
 

## Project Structure
```
 .
├── modules
|    └── events
|        └── main.tf
|        └── outputs.tf
|        └── variables.tf
│    └── functions
|        └── lambda_function_payload.zip
|        └── main.tf
|        └── outputs.tf
|        └── variables.tf
|    └── secrets
|        └── main.tf
|        └── outputs.tf
|        └── variables.tf    
├── backend.tf
├── main.tf                    # Main Terraform
├── terraform.tf
├── README.MD                  # README


