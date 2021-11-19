#!/bin/bash

SM_MR_NS=$1
SM_REMOTE_ROUTE=$2
# eg. fail (503 default) or success (200)
STATE=$3

echo 'ServiceMesh Member Namespace               : '$SM_MR_NS
echo 'ServiceMesh (Remote) Ingress Gateway Route : '$SM_REMOTE_ROUTE	
echo 'State to be returned (503/200)             : '$STATE

cd ../coded-services/quarkus-rest-503
oc project  $SM_MR_NS

mvn clean package -Dquarkus.kubernetes.deploy=true -DskipTests

echo 'sleeping 15s'
sleep 15
oc patch dc/quarkus-rest-503 -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "true"}}}}}' -n  $SM_MR_NS
oc set env dc/quarkus-rest-503 ERROR_FLAG=$STATE -n  $SM_MR_NS

oc rollout latest dc/quarkus-rest-503  -n  $SM_MR_NS
  
echo "################# Gateway - quarkus-rest-503-gateway [$SM_MR_NS] #################"     
echo "apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: quarkus-rest-503-gateway
spec:
  selector:
    istio: ingressgateway # use istio default controller
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - ${SM_REMOTE_ROUTE}
  exportTo:
    - '*'" | oc apply -n $SM_MR_NS -f -  

echo "################# VirtualService - quarkus-rest-503 [$SM_MR_NS] #################"     
echo "apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: quarkus-rest-503
spec:
  hosts:
  - ${SM_REMOTE_ROUTE}
  - rest-greeting-remote.${SM_MR_NS}.svc.cluster.local
  gateways:
  - quarkus-rest-503-gateway
  - mesh
  http:
  - match:
    - uri:
        exact: /status
    - uri:
        prefix: /status
    route:
    - destination:
        host: quarkus-rest-503.${SM_MR_NS}.svc.cluster.local
        port:
          number: 8080
  exportTo:
    - '*'" | oc apply -n $SM_MR_NS -f -  
  
  
  
    
