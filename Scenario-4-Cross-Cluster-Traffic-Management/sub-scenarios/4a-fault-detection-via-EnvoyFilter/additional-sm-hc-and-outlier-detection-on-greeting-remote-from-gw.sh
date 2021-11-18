#!/bin/bash

SERVICE_NAME=$1
SERVICE_NAMESPACE=$2
SERVICE_HEALTHCHECK_URI=$3
GW_APP_NAME=$4
GW_NAMESPACE=$4


echo "################# EnvoyFilter - ${SERVICE_NAME}-status-check-healthcheck [$GW_NAMESPACE] #################"
echo "apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: ${SERVICE_NAME}-status-check-healthcheck
spec:
  workloadSelector:
    labels:
      app: ${GW_APP_NAME}
  configPatches:
    - applyTo: CLUSTER
      match:
        cluster:
          service: ${SERVICE_NAME}.${SERVICE_NAMESPACE}.svc.cluster.local
        context: GATEWAY
      patch:
        operation: MERGE
        value:
          health_checks:
            - always_log_health_check_failures: true
              event_log_path: /dev/stdout
              healthy_threshold: 1
              http_health_check:
                host: >-
                  ${SERVICE_NAME}.${SERVICE_NAMESPACE}.svc.cluster.local
                path: ${SERVICE_HEALTHCHECK_URI}
              interval: 5s
              timeout: 5s
              unhealthy_threshold: 1"
              
echo "apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: ${SERVICE_NAME}-status-check-healthcheck
spec:
  workloadSelector:
    labels:
      app: ${GW_APP_NAME}
  configPatches:
    - applyTo: CLUSTER
      match:
        cluster:
          service: ${SERVICE_NAME}.${SERVICE_NAMESPACE}.svc.cluster.local
        context: GATEWAY
      patch:
        operation: MERGE
        value:
          health_checks:
            - always_log_health_check_failures: true
              event_log_path: /dev/stdout
              healthy_threshold: 1
              http_health_check:
                host: >-
                  ${SERVICE_NAME}.${SERVICE_NAMESPACE}.svc.cluster.local
                path: ${SERVICE_HEALTHCHECK_URI}
              interval: 5s
              timeout: 5s
              unhealthy_threshold: 1" | oc apply -n $GW_NAMESPACE -f -                
              
echo "################# EnvoyFilter - ${SERVICE_NAME}-status-check-healthcheck [$GW_NAMESPACE] #################"
echo "kind: DestinationRule
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: ${SERVICE_NAME}-503-outlier-detection-dr
spec:
  host: ${SERVICE_NAME}.${SERVICE_NAMESPACE}.svc.cluster.local
  trafficPolicy:
    outlierDetection:
      baseEjectionTime: 1m
      consecutive5xxErrors: 1
      interval: 30s
      maxEjectionPercent: 100"
      
echo "kind: DestinationRule
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: ${SERVICE_NAME}-503-outlier-detection-dr
spec:
  host: ${SERVICE_NAME}.${SERVICE_NAMESPACE}.svc.cluster.local
  trafficPolicy:
    outlierDetection:
      baseEjectionTime: 1m
      consecutive5xxErrors: 1
      interval: 30s
      maxEjectionPercent: 100" | oc apply -n $GW_NAMESPACE -f - 

