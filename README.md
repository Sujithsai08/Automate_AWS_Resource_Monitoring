# Automated AWS Resource Management Script

## Overview

This repository contains a Bash script designed to automate the monitoring and management of AWS resources. As students, we often forget to stop or terminate AWS resources after use, leading to unnecessary costs. This script checks for active AWS resources daily at 2:00 AM using a cron job and sends notifications via AWS SNS if instances, S3 buckets, or Lambda functions are running. It also alerts if an EC2 instance's CPU utilization, S3 bucket storage, or Lambda function invocations and errors exceed specified thresholds.

## Features

- **EC2 Instance Monitoring**: Identifies running instances and checks CPU utilization against a threshold.
- **S3 Bucket Monitoring**: Lists active buckets and checks their storage sizes against a threshold.
- **Lambda Function Monitoring**: Lists active functions and checks their invocation rates and error counts against thresholds.
- **Automated Alerts**: Sends email notifications via AWS SNS for active resources and threshold breaches.

## Prerequisites

- AWS CLI configured with appropriate IAM permissions.
- AWS SNS Topic ARN for sending notifications.
- `bc` utility for floating-point arithmetic.

## Setup

1. **Clone the Repository**:
    ```bash
    git clone https://github.com/yourusername/aws-resource-management-script.git
    cd aws-resource-management-script
    ```

2. **Configure AWS CLI**:
    Ensure the AWS CLI is configured with appropriate IAM permissions to access EC2, S3, Lambda, CloudWatch, and SNS services.

3. **Set Up Environment Variables**:
    Update the script with your AWS region and SNS Topic ARN.

    ```bash
    REGION='us-east-1'  # Your AWS region
    SNS="arn:aws:sns:us-east-1:701088230187:alert"  # Your SNS Topic ARN
    ```

4. **Set Up Cron Job**:
    Schedule the script to run daily at 2:00 AM by adding the following line to your crontab file:

    ```bash
    0 2 * * * /path/to/your/script.sh
    ```

## Script Usage

### alert Function

Sends a notification via AWS SNS.

```bash
alert() {
    local message="$1"
    local subject="$2"
    aws sns publish --region $REGION --topic-arn "$SNS" --message "$message" --subject "$subject"
}
