#!/bin/bash

NAMESPACE=$1
ISTIO_NAMESPACE=$2

echo '-------------------------------------------------------------------------'
echo 'application namespace      : '$NAMESPACE
echo 'istio namespace      	 : '$ISTIO_NAMESPACE
echo '-------------------------------------------------------------------------'

echo "################# Create - namespace for Istio SMCP [$ISTIO_NAMESPACE] #################" 

oc new-project $ISTIO_NAMESPACE

sleep 5

echo "################# Create - ServiceMeshControlPlane in [$ISTIO_NAMESPACE] #################" 

echo "apiVersion: maistra.io/v2
kind: ServiceMeshControlPlane
metadata:
  name: tenant-certs
spec:
  policy:
    type: Istiod
  addons:
    grafana:
      enabled: true
    jaeger:
      install:
	storage:
	  type: Memory
    kiali:
      enabled: true
    prometheus:
      enabled: true
  general:
    logging:
      logAsJSON: true
  profiles:
    - default
  proxy:
    accessLogging:
      file:
	name: /dev/stdout
    networking:
      trafficControl:
	inbound: {}
	outbound:
	  policy: REGISTRY_ONLY
  telemetry:
    type: Istiod
  tracing:
    sampling: 10000
    type: Jaeger
  version: v2.1" | oc apply -n $ISTIO_NAMESPACE -f -
  
sleep 5  
  
echo "################# Create - namespace for Application [$NAMESPACE] #################" 

oc new-project $NAMESPACE

echo "################# Create - ServiceMeshMemberRoll with [$NAMESPACE] #################"   

sleep 5
  
echo "apiVersion: maistra.io/v1
	kind: ServiceMeshMemberRoll
	metadata:
	  namespace: istio-system-certs
	  name: default
	spec:
	  members:
	    - $NAMESPACE" | oc apply -n $ISTIO_NAMESPACE -f -   
  
sleep 5  
  
