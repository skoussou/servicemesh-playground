#!/bin/bash

SM_CP_NS=$1
SM_TENANT_NAME=$2

echo '---------------------------------------------------------------------------'
echo 'ServiceMesh Namespace                      : '$SM_CP_NS
echo 'ServiceMesh Control Plane Tenant Name      : '$SM_TENANT_NAME
echo '---------------------------------------------------------------------------'

echo "############# Creating SM Tenant [$SM_TENANT_NAME] in Namespace [$SM_CP_NS ] #############"
echo "apiVersion: maistra.io/v2
kind: ServiceMeshControlPlane
metadata:
  name: $SM_TENANT_NAME
spec:
  security:
    dataPlane:
      automtls: false
      mtls: true
  tracing:
    sampling: 10000
    type: Jaeger
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
  version: v2.1
  telemetry:
    type: Istiod"
    
echo "apiVersion: maistra.io/v2
kind: ServiceMeshControlPlane
metadata:
  name: $SM_TENANT_NAME
spec:
  security:
    dataPlane:
      automtls: false
      mtls: true
  tracing:
    sampling: 10000
    type: Jaeger
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
  version: v2.1
  telemetry:
    type: Istiod"| oc apply -n $SM_CP_NS -f -

echo "oc wait --for condition=Ready -n $FED_1_SMCP_NAMESPACE smcp/$FED_1_SMCP_NAME --timeout 300s"
#oc wait --for condition=Ready -n $FED_1_SMCP_NAMESPACE smcp/$FED_1_SMCP_NAME --timeout 300s

