#!/bin/bash

SM_CP_NS=$1
SM_TENANT_NO=$2
SM_MR_NS=$3

echo 'ServiceMesh Namespace '$SM_CP_NS
echo 'ServiceMesh tenant-'$SM_TENANT_NO
echo 'ServiceMesh Member Namespace '$SM_MR_NS

#oc apply -f smcp-2.0.yaml -n $SM_CP_NS

echo "apiVersion: maistra.io/v2
kind: ServiceMeshControlPlane
metadata:
  name: tenant-$SM_TENANT_NO
spec:
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
  policy:
    type: Istiod
  profiles:
    - default
  proxy:
    accessLogging:
      file:
        name: /dev/stdout
    networking:
      trafficControl:
        outbound:
          policy: REGISTRY_ONLY
  gateways:
    additionalIngress:
      admin-ingressgateway:
        enabled: true
        runtime:
          deployment:
            autoScaling:
              enabled: false
        service:
          metadata:
            labels:
              app: admin-ingressgateway
          selector:
            app: admin-ingressgateway          
  telemetry:
    type: Istiod
  tracing:
    sampling: 10000
    type: Jaeger
  version: v2.0" | oc apply -n $SM_CP_NS -f -    



echo "apiVersion: maistra.io/v1
kind: ServiceMeshMemberRoll
metadata:
  name: default
spec:
  members:
    - ${SM_MR_NS}" | oc apply -n $SM_CP_NS -f -    
    
    
