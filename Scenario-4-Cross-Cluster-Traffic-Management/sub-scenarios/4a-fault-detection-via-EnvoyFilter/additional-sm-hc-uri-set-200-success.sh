#!/bin/bash

SERVICE_POD_NAME=$1
SERVICE_NAME=$2
SERVICE_NAMESPACE=$3

echo "oc exec $SERVICE_POD_NAME --n $SERVICE_NAMESPACE -- curl -iv -X GET http://$SERVICE_NAME.$SERVICE_NAMESPACE.svc.cluster.local:8080/status/set/succeed"

oc exec $SERVICE_POD_NAME -n $SERVICE_NAMESPACE -- curl -iv -X GET http://$SERVICE_NAME.$SERVICE_NAMESPACE.svc.cluster.local:8080/status/set/succeed
