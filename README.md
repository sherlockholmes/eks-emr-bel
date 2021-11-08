# eks-emr-bel
EMR EKS BEL Scripts

Seguir las indicaciones para crear un cloud9 dedicado para la tarea.

https://www.eksworkshop.com/020_prerequisites/workspace/


sudo curl --silent --location -o /usr/local/bin/kubectl \
https://storage.googleapis.com/kubernetes-release/release/v1.22.0/bin/linux/amd64/kubectl

sudo chmod +x /usr/local/bin/kubectl


curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install


sudo yum -y install jq gettext bash-completion moreutils

echo 'yq() {
  docker run --rm -i -v "${PWD}":/workdir mikefarah/yq "$@"
}' | tee -a ~/.bashrc && source ~/.bashrc

for command in kubectl jq envsubst aws
  do
    which $command &>/dev/null && echo "$command in path" || echo "$command NOT FOUND"
  done


kubectl completion bash >>  ~/.bash_completion
. /etc/profile.d/bash_completion.sh
. ~/.bash_completion


echo 'export LBC_VERSION="v2.3.0"' >>  ~/.bash_profile
.  ~/.bash_profile


Crear un IAM role como menciona en la documentacion 

https://www.eksworkshop.com/020_prerequisites/iamrole/

Y vincularlo con el cloud9

https://www.eksworkshop.com/020_prerequisites/ec2instance/

Tambien 

https://www.eksworkshop.com/020_prerequisites/workspaceiam/

Por ultimo crear el KMS Key

https://www.eksworkshop.com/020_prerequisites/kmskey/


curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

sudo mv -v /tmp/eksctl /usr/local/bin

eksctl version

eksctl completion bash >> ~/.bash_completion
. /etc/profile.d/bash_completion.sh
. ~/.bash_completion

Edita el archivo tags.sh en la primera linea colocar todas las subredes de la vpc

en la segunda solo las subredes internas

en la primera solo las publicas

luego ejecutar el archivo 

chmod +x tags.sh 

./tags.sh


Editar el archivo eksbel.yml modificar vpcids, subnetids, etc

luego ejecutar el siguiente comando para crear el cluster.

eksctl create cluster -f eksbel.yml

esperar

kubectl create namespace spark

eksctl create iamidentitymapping \
    --cluster eksbel-dev \
    --namespace spark \
    --service-name "emr-containers"
    
eksctl utils associate-iam-oidc-provider --cluster eksbel-dev --approve

cat <<EoF > ~/environment/emr-trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticmapreduce.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EoF

aws iam create-role --role-name EMRContainers-JobExecutionRole --assume-role-policy-document file://emr-trust-policy.json

cat <<EoF > ~/environment/EMRContainers-JobExecutionRole.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams"
            ],
            "Resource": [
                "arn:aws:logs:*:*:*"
            ]
        }
    ]
}  
EoF
aws iam put-role-policy --role-name EMRContainers-JobExecutionRole --policy-name EMR-Containers-Job-Execution --policy-document file://~/environment/EMRContainers-JobExecutionRole.json

aws emr-containers update-role-trust-policy --cluster-name eksbel-dev --namespace spark --role-name EMRContainers-JobExecutionRole

aws emr-containers create-virtual-cluster \
--name eks-bel-dev \
--container-provider '{
    "id": "eksbel-dev",
    "type": "EKS",
    "info": {
        "eksInfo": {
            "namespace": "spark"
        }
    }
}'