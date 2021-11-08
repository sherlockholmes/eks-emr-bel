eksctl create iamidentitymapping \
    --cluster eksbel-dev \
    --namespace sparkdev \
    --service-name "emr-containers"

aws emr-containers create-virtual-cluster \
--name emr_eks_cluster_fargate \
--container-provider '{
    "id":   "'"eksbel-dev"'",
    "type": "EKS",
    "info": {
        "eksInfo": {
            "namespace": "sparkdev"
        }
    }
}'    

# Setup the Trust Policy for the IAM Job Execution Role

aws emr-containers update-role-trust-policy \
       --cluster-name eksbel-dev \
       --namespace dev \
       --role-name eksbeladmin

eksctl utils associate-iam-oidc-provider --cluster eksbel-dev --approve

