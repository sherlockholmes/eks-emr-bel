#!/bin/bash

echo "tagging shared"
aws ec2 create-tags \
  --resources "subnet-07fbedd0910b82329" "subnet-019feda4e575ad3bb" "subnet-04ceaa17e7b24107e" "subnet-013c7665373a4d20d" \
  --tags Key="kubernetes.io/cluster/eksbel-dev",Value=shared

echo "tagging private"
aws ec2 create-tags \
  --resources "subnet-04ceaa17e7b24107e" "subnet-013c7665373a4d20d" \
  --tags Key=kubernetes.io/role/internal-elb,Value=1

echo "tagging public"
aws ec2 create-tags \
  --resources "subnet-07fbedd0910b82329" "subnet-019feda4e575ad3bb" \
  --tags Key=kubernetes.io/role/elb,Value=1kub 