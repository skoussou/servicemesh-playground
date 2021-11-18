#!/bin/bash

GW_APP_NAME=$1
GW_NAMESPACE=$2
SERVICE_NAMESPACE=$3
GW_ROUTE=$(oc get route $GW_APP_NAME -o jsonpath='{.spec.host}' -n $GW_NAMESPACE)


echo "GW_APP_NAME: 	 $GW_APP_NAME" 
echo "GW_NAMESPACE: 	 $GW_NAMESPACE" 
echo "SERVICE_NAMESPACE: $SERVICE_NAMESPACE" 
echo "GW_ROUTE:		 $GW_ROUTE"
echo ''
echo "################# Gateway - rest-greeting-remote-${GW_APP_NAME} [${SERVICE_NAMESPACE}] #################"     
echo "apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: rest-greeting-remote-${GW_APP_NAME}
spec:
  selector:
    app: ${GW_APP_NAME}
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - ${GW_ROUTE}"


echo "apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: rest-greeting-remote-${GW_APP_NAME}
spec:
  selector:
    app: ${GW_APP_NAME}
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - ${GW_ROUTE}" | oc apply -n $SERVICE_NAMESPACE -f -

echo "################# VirtualService - rest-greeting-remote-${GW_APP_NAME} [${SERVICE_NAMESPACE}] #################"     
echo "apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: rest-greeting-remote-${GW_APP_NAME}-vs
spec:
  hosts:
  - ${GW_ROUTE}
  gateways:
  - rest-greeting-${GW_APP_NAME}
  - mesh
  http:
  - match:
    - uri:
        exact: /hello
    - uri:
        prefix: /hello
    route:
    - destination:
        host: rest-greeting-remote
        port:
          number: 8080"


echo "apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: rest-greeting-remote-${GW_APP_NAME}-vs
spec:
  hosts:
  - ${GW_ROUTE}
  gateways:
  - rest-greeting-remote-${GW_APP_NAME}
  - mesh
  http:
  - match:
    - uri:
        exact: /hello
    - uri:
        prefix: /hello
    route:
    - destination:
        host: rest-greeting-remote
        port:
          number: 8080"| oc apply -n $SERVICE_NAMESPACE -f -

