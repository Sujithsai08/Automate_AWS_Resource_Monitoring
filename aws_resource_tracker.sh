#!/bin/bash

##########
# Author: Sujith Sai ##mention your name here
# Date :20-06-2024
# This script automates the process of tracking aws resources 

#########


REGION='us-east-1' # mention your aws region here

SNS="arn:aws:sns:us-east-1:701088230187:alert" # mention your arn here

alert(){
    local message="$1"
    local subject="$2"

    aws sns publish --region $REGION --topic-arn "$SNS" --message "$message" --subject "$subject"
}



check_ec2(){

    echo "listing ec2 instances...."

    local cpu_threshold=5 #mention your cpu_threshold here
        local start_time=$(date -u -d '15 minutes ago' +%FT%T)
    local end_time=$(date -u +%FT%T)
    local period=300
    Running_instances=$(aws ec2 describe-instances --region "$REGION" --filters Name=instance-state-name,Values=running --query "Reservations[*].Instances[*].InstanceId" --output text)
    if [ -z "$Running_instances" ]; then
        echo "no instances are running"
    else


        alert "Instance : $Running_instances is currently running please stop/terminate it..." "Active instances alert"

        for instance in $Running_instances;do
            local utilization=$(aws cloudwatch get-metric-statistics --region "$REGION" --namespace AWS/EC2 --metric-name CPUUtilization --dimensions Name=InstanceId,Value="$instance" --start-time "$start_time" --end-time "$end_time" --period "$period" --statistics Average --query 'Datapoints[0].Average' --output text)

             if (( $(echo "$utilization > $cpu_threshold" | bc -l) ));then
                 alert "High cpu usage detected:$utilization on instance :$Running_instances" "cpu usage alert"
                else
                    echo "cpu usage : $utilization on instance : $Running_instances"
             fi
         done
    fi
}

check_s3(){
    echo " listing s3 buckets ...."
local s3_buckets=$(aws s3api list-buckets --query "Buckets[].Name" --output text)

if [ -z "$s3_buckets" ];then
    echo "no buckets found"
else
    alert "buckets  :$s3_buckets is currently active please stop/terminate it" "Active buckets alert"

    for bucket in $s3_buckets; do
        echo "Bucket: $bucket"


        local storage_info=$(aws s3 ls s3://$bucket --summarize --human-readable | tail -n1)



            local current_size=$(echo "$storage_info" | awk '{print $3}')

            echo "Current Size: $current_size"
        local threshold="100 KiB"  #mention your s3_bucket threshold here

                      if (( $(echo "$current_size" ">" "$threshold" | bc -l) )); then
                echo "High storage detected: ${current_size} on bucket: $bucket"

                alert "High storage detected: ${current_size} on bucket: $bucket" "S3 Storage Alert"
            fi


        echo
    done
fi
}

check_lambda() {
    echo "Listing Lambda functions..."
    local lambda_functions=$(aws lambda list-functions --region "$REGION" --query "Functions[].FunctionName" --output text)

    if [ -z "$lambda_functions" ]; then
        echo "No Lambda functions found"
    else
        alert "lambda function : $lamda_functions found... please stop/terminate it"

        local invocation_threshold=100  
        local error_threshold=1         

        for function in $lambda_functions; do
            echo "Checking usage for Lambda function: $function"


            local invocations=$(aws cloudwatch get-metric-statistics --region "$REGION" --namespace AWS/Lambda --metric-name Invocations \
                --dimensions Name=FunctionName,Value="$function" --start-time $(date -u -d '1 day ago' +%FT%T) --end-time $(date -u +%FT%T) \
                --period 86400 --statistics Sum --query 'Datapoints[0].Sum' --output text)


            local errors=$(aws cloudwatch get-metric-statistics --region "$REGION" --namespace AWS/Lambda --metric-name Errors \
                --dimensions Name=FunctionName,Value="$function" --start-time $(date -u -d '1 day ago' +%FT%T) --end-time $(date -u +%FT%T) \
                --period 86400 --statistics Sum --query 'Datapoints[0].Sum' --output text)

            invocations=${invocations:-0}
            errors=${errors:-0}

            echo "Invocations: $invocations"
            echo "Errors: $errors"

            if (( $(echo "$invocations > $invocation_threshold" | bc -l) )); then
                echo "High invocation count detected: $invocations for function: $function"
                alert "High invocation count detected: $invocations for function: $function" "Lambda Usage Alert"
            fi

            if (( $(echo "$errors > $error_threshold" | bc -l) )); then
                echo "Errors detected: $errors for function: $function"
                alert "Errors detected: $errors for function: $function" "Lambda Error Alert"
            fi

            echo 
    done
    fi
}

check_ec2
check_s3
check_lambda
