import boto3
import os
import json

ec2 = boto3.client('ec2')
sns = boto3.client('sns')

# Variables passed from Terraform
QUARANTINE_SG = os.environ['QUARANTINE_SG_ID']
SNS_TOPIC = os.environ['SNS_TOPIC_ARN']

def lambda_handler(event, context):
    print("Event Received:", json.dumps(event))
    
    try:
        # 1. Parse GuardDuty Finding
        detail = event['detail']
        finding_type = detail['type']
        
        # GuardDuty findings for EC2 instances usually have this structure
        instance_id = detail['resource']['instanceDetails']['instanceId']
        
        print(f"Alert: {finding_type} on Instance: {instance_id}")
        
        # 2. Quarantine the Instance
        print(f"Applying Quarantine SG: {QUARANTINE_SG} to {instance_id}")
        ec2.modify_instance_attribute(
            InstanceId=instance_id,
            Groups=[QUARANTINE_SG]
        )
        
        # 3. Send Notification
        message = f"SECURITY ALERT: GuardDuty detected {finding_type}. Instance {instance_id} has been QUARANTINED."
        sns.publish(
            TopicArn=SNS_TOPIC,
            Message=message,
            Subject="Auto-Remediation Triggered"
        )
        
        return {"status": "success", "instance": instance_id}

    except KeyError:
        print("Not an EC2 finding or missing instance ID.")
        return {"status": "ignored"}
    except Exception as e:
        print(f"Error: {str(e)}")
        raise e
