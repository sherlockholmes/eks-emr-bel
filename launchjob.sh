aws emr-containers start-job-run \
  --virtual-cluster-id=mtlb0a4gj69b1xraj282tc6oo \
  --name=pi-3 \
  --execution-role-arn=arn:aws:iam::297537572205:role/EMRContainers-JobExecutionRole\
  --release-label=emr-6.2.0-latest \
--job-driver '{
    "sparkSubmitJobDriver": {
        "entryPoint": "local:///usr/lib/spark/examples/src/main/python/pi.py",
        "sparkSubmitParameters": "--conf spark.executor.instances=2 --conf spark.executor.memory=2G --conf spark.executor.cores=2 --conf spark.driver.cores=1"
        }
    }' \
--configuration-overrides '{
    "applicationConfiguration": [
      {
        "classification": "spark-defaults", 
        "properties": {
          "spark.driver.memory":"2G"
         }
      }
    ], 
    "monitoringConfiguration": {
      "cloudWatchMonitoringConfiguration": {
        "logGroupName": "/emr-containers/jobs", 
        "logStreamNamePrefix": "emr-eks-workshop"
      }, 
      "s3MonitoringConfiguration": {
        "logUri": "s3://emr-eks-bel-rh/logs/"
      }
    }
}'