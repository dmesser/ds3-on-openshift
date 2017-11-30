#!/bin/bash

## break on any non-zero exit codes
set -e

## volume size in GB (needs to be a bit larger than dbsize)
volsize=5

## database size in GB
dbsize=1
dbtype=mysql

## wait timeout to for operations to complete, in seconds
timeout=30

echo "Create source PVC"

## create the source PVC
oc process -f ds3-generate-volume-template.yml    \
           -p SOURCE_VOLUME_CAPACITY=${volsize}Gi \
           -p STORAGE_CLASS=cns                   \
           | oc create -f -

echo -n "Waiting for PVC ds3-source-data to become bound"

## wait for source PVC to be bound
for (( timer=0 ; timer < ${timeout} ; timer++ ))
do
  if [[ $(oc get pvc/ds3-source-data -o jsonpath='{.status.phase}') == "Bound" ]]
  then
    echo
    echo "PVC ds3-source-data is in state:" $(oc get pvc/ds3-source-data -o jsonpath='{.status.phase}')
    break;
  elif [[ $((${timer}+1)) -eq ${timeout} ]]
  then
    echo
    echo "PVC ds3-source-data did not show up or wasn't bound in time, exiting"
    exit 1
  else
    echo -n "."
    sleep 1s
  fi
done

echo "Create job to generate a ${dbsize}GB ${dbtype} database"

## create data generator as Kubernetes Job
oc process -f ds3-generate-job-template.yml \
           -p DB_SIZE=${dbsize}             \
           -p DB_TYPE=${dbtype}             \
           | oc create -f -

echo -n "Waiting for job ds3-generate-data to become active"

## wait for job to be started
for (( timer=0 ; timer < ${timeout} ; timer++ ))
do
 if [[ $(oc get pod -l job-name=ds3-generate-data -o jsonpath='{.items[0].status.phase}') == "Running" ]]
 then
   echo
   echo "Job ds3-generate-data is active"
   break;
 elif [[ $((${timer}+1)) -eq ${timeout} ]]
 then
   echo
   echo "Job ds3-generate-data has not become active in time"
   exit 1
 else
   echo -n "."
   sleep 1s
 fi
done

echo "Attaching to job log"

oc logs -f job/ds3-generate-data
