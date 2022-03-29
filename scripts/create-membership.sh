#!/bin/bash

ISTIO_NAMESPACE=$1
ISTIO_TENANT_NAME=$2
APP_NAMESPACE=$3
SERVICE_MESH_MEMBER_RESOURCE_NAME=default

echo '-------------------------------------------------------------------------'
echo 'Istio Namespace         : '$ISTIO_NAMESPACE
echo 'Istio SMCP Name         : '$ISTIO_TENANT_NAME
echo 'App Namespace           : '$APP_NAMESPACE
echo 'SMR Resource Name       : '$SERVICE_MESH_MEMBER_RESOURCE_NAME

echo '-------------------------------------------------------------------------'


echo "################# ServiceMeshMeber - [$SERVICE_MESH_MEMBER_RESOURCE_NAME] for [$APP_NAMESPACE]  #################" 

echo "apiVersion: maistra.io/v1
kind: ServiceMeshMember
metadata:
  namespace: $APP_NAMESPACE
  name: $SERVICE_MESH_MEMBER_RESOURCE_NAME
spec:
  controlPlaneRef:
    name: $ISTIO_TENANT_NAME
    namespace: $ISTIO_NAMESPACE"


echo "apiVersion: maistra.io/v1
kind: ServiceMeshMember
metadata:
  namespace: $APP_NAMESPACE
  name: $SERVICE_MESH_MEMBER_RESOURCE_NAME
spec:
  controlPlaneRef:
    name: $ISTIO_TENANT_NAME
    namespace: $ISTIO_NAMESPACE" |oc apply -f -    
