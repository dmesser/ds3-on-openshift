#!/bin/bash

## break on any non-zero exit codes
set -e

## name of the StorageClass to use for the PVC
storageclass=cns

## mysql credentials
mysql_user=ds3
mysql_pass=toomanysecrets

## mysql database volume size in GB (should be source data plus some headroom)
mysql_size=10

## amount of memory in GB to limit the mysql instance to
mysql_ram=5

## external IP of the master instance
mysql_ip=''

## wait timeout to for operations to complete, in seconds
timeout=120

echo "Create MySQL Master instance and PVC"

## create the whole mysql stack
oc process -f ds3-mysql-master-template.yml             \
           -p MYSQL_VOLUME_CAPACITY=${mysql_size}Gi     \
           -p MYSQL_MEMORY_LIMIT=${mysql_ram}Gi         \
           -p APP_NAME=ds3-mysql-master                 \
           -p MYSQL_USER=${mysql_user}                  \
           -p MYSQL_PASSWORD=${mysql_pass}              \
           -p STORAGE_CLASS=${storageclass}             \
           -p EXTERNAL_IP=${mysql_ip}                   \
           | oc create -f -

echo -n "Waiting for MySQL master deployment to be ready"

## wait for replicationcontroller to signal readiness
for (( timer=0 ; timer < ${timeout} ; timer++ ))
do
 if [[ $(oc get rc -l openshift.io/deployment-config.name=ds3-mysql-master-database -o jsonpath='{$.items[?(@.spec.selector.deploymentconfig=="ds3-mysql-master-database")].status.readyReplicas}') == "1" ]]
 then
   echo
   echo "MySQL Master instance is ready"
   break;
 elif [[ $((${timer}+1)) -eq ${timeout} ]]
 then
   echo
   echo "MySQL Master instance has not become ready before the timeout"
   exit 1
 else
   echo -n "."
   sleep 1s
 fi
done

echo "Getting external ingress point of MySQL instance..."

#mysql_external_ip=$(oc get svc/ds3-mysql-master-database -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
mysql_external_ip=$(oc get svc/ds3-mysql-master-database -o jsonpath='{.spec.clusterIP}')

if [[ ${mysql_external_ip} == "" ]]; then
  echo "Could not determine external ingress point of MySQL master"
  exit 1
else
  echo -n ${mysql_external_ip}
fi

echo "Checking source PVC"

oc get pvc/ds3-source-data

echo "Loading data set from source PV to MySQL Master instance"

## create the data loader job
oc process -f ds3-load-job-template.yml         \
           -p MYSQL_USER=${mysql_user}          \
           -p MYSQL_PASSWORD=${mysql_pass}      \
           -p MYSQL_HOST=${mysql_external_ip}   \
           | oc create -f -

echo -n "Waiting for job ds3-load-data to become active"

## wait for job to be started
for (( timer=0 ; timer < ${timeout} ; timer++ ))
do
 if [[ $(oc get pod -l job-name=ds3-load-data -o jsonpath='{.items[0].status.phase}') == "Running" ]]
 then
   echo
   echo "Job ds3-load-data is active"
   break;
 elif [[ $((${timer}+1)) -eq ${timeout} ]]
 then
   echo
   echo "Job ds3-load-data has not become active in time"
   exit 1
 else
   echo -n "."
   sleep 1s
 fi
done

echo "Attaching to job log"

oc logs -f job/ds3-load-data
