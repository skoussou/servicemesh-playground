#!/bin/bash

NAMESPACE=$1

echo '-------------------------------------------------------------------------'
echo 'hello-openshift deployed in namespace      : '$NAMESPACE
echo '-------------------------------------------------------------------------'


echo "################# Gateway - hello-openshift-gateway [$NAMESPACE] #################"             

echo "apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: hello-openshift-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: hello-openshift
      protocol: HTTP
    hosts:
    - '*'" | oc apply -n $NAMESPACE -f -    



echo "################# VirtualService - hello-openshift [$NAMESPACE] #################"   
echo "apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: hello-openshift
spec:
  gateways:
  - hello-openshift-gateway
  hosts:
  - '*'
  http:
    - match:
        - uri:
            exact: /
      route:
        - destination:
            host: hello-openshift
            port:
              number: 8080" | oc apply -n $NAMESPACE -f -     
