# Automated AWS Resource Management Script

## Introduction

Managing AWS resources effectively is crucial to avoid unexpected costs and ensure optimal performance. As students, we often forget to stop or terminate AWS resources after use, leading to unnecessary expenses. To address this challenge, I have created a Bash script that automates the monitoring and management of AWS resources. This script runs daily at 2:00 AM using a cron job and sends notifications via AWS SNS if instances, S3 buckets, or Lambda functions are active. It also sends alerts if an EC2 instance's CPU utilization, S3 bucket storage, or Lambda function invocations and errors exceed specified thresholds.

## Overview

This repository contains a Bash script designed to automate the daily monitoring of AWS resources. The script checks for active EC2 instances, S3 buckets, and Lambda functions and sends notifications if certain thresholds are exceeded. This automation helps in managing resources efficiently, preventing unnecessary costs, and ensuring optimal resource usage.

## Features

- **EC2 Instance Monitoring**:
  - Identifies running instances.
  - Checks CPU utilization against a specified threshold.
  - Sends alerts if instances are running or if CPU utilization exceeds the threshold.

- **S3 Bucket Monitoring**:
  - Lists all active buckets.
  - Checks storage sizes against a specified threshold.
  - Sends alerts if storage exceeds the threshold.

- **Lambda Function Monitoring**:
  - Lists all active Lambda functions.
  - Checks invocation rates and error counts against specified thresholds.
  - Sends alerts if invocations or errors exceed the thresholds.

- **Automated Alerts**:
  - Sends email notifications via AWS SNS for active resources and threshold breaches.

## Prerequisites

- AWS CLI configured with appropriate IAM permissions.
- AWS SNS Topic ARN for sending notifications.
- `bc` utility for floating-point arithmetic.

## Setup

### Clone the Repository

```bash
git clone https://github.com/sujithsai08/aws-resource-management-script.git
cd aws_resource_tracker

Configure AWS CLI
Ensure the AWS CLI is configured with appropriate IAM permissions to access EC2, S3, Lambda, CloudWatch, and SNS services.

Set Up Environment Variables
Update the script with your AWS region and SNS Topic ARN.
REGION='us-east-1'  # Your AWS region
SNS="arn:aws:sns:us-east-1:701088230187:alert"  # Your SNS Topic ARN
###execute 
./sh aws_resource_tracker.sh

