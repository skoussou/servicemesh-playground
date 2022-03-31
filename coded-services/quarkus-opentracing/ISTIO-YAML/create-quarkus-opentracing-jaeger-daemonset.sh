#!/bin/bash

SM_CP_NS=$1
SM_TENANT_NAME=$2
SM_MR_NS=$3
SM_REMOTE_ROUTE=$4

echo
echo '---------------------------------------------------------------------------'
echo 'ServiceMesh Control Plane Namespace        : '$SM_CP_NS
echo 'ServiceMesh Control Plane Tenant Name      : '$SM_TENANT_NAME
echo 'ServiceMesh Member Namespace               : '$SM_MR_NS
echo 'Remote SMCP Route Name                     : '$SM_REMOTE_ROUTE
echo '---------------------------------------------------------------------------'
echo

#cd ../../coded-services/quarkus-opentracing
cd ../
oc new-project $SM_MR_NS
oc project  $SM_MR_NS

mvn clean package -Dquarkus.kubernetes.deploy=true -DskipTests

echo 'sleeping 15s'
sleep 15
oc patch dc/hello-traced-quarkus-service -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "true"}}}}}' -n  $SM_MR_NS
oc patch dc/hello-traced-quarkus-service --type=json --patch '
[
  { 
    "op": "add",
    "path": "/spec/template/spec/containers/0/env",
    "value": [
        {
            "name": "JAEGER_AGENT_HOST",
            "valueFrom": {
                "fieldRef": {
                    "apiVersion": "v1",
                    "fieldPath": "status.hostIP"                    
                }
            }
        }
     ]
  }        
]'   -n  $SM_MR_NS

echo
echo "################# SMR [default] added in SMCP [ns:$SM_CP_NS name: $SM_TENANT_NAME] #################"   
echo "sh  ../../scripts/create-membership.sh $SM_CP_NS $SM_TENANT_NAME $SM_MR_NS"
sh ../../scripts/create-membership.sh $SM_CP_NS $SM_TENANT_NAME $SM_MR_NS
   
oc rollout latest dc/hello-traced-quarkus-service  -n  $SM_MR_NS

              
echo "################# Gateway - opentracing-hello-gateway [$SM_CP_NS] #################"   
echo "kind: Gateway
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: opentracing-hello-gateway
spec:
  servers:
    - hosts:
        - '*'
      port:
        name: http-hello-traced-quarkus-service
        number: 80
        protocol: HTTP
  selector:
    istio: ingressgateway"|oc apply -n $SM_MR_NS -f -      

   
echo "################# VirtualService - opentracing-hello [$SM_CP_NS] #################"      
echo "kind: VirtualService
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: opentracing-hello
spec:
  hosts:
    - '*'
  gateways:
    - opentracing-hello-gateway
  http:
    - match:
        - uri:
            exact: /chain
        - uri:
            exact: /hello
      route:
        - destination:
            host: hello-traced-quarkus-service
            port:
              number: 8080"|oc apply -n $SM_MR_NS -f -

echo       
echo "################# TESTING [http://${SM_REMOTE_ROUTE}/chain]  #################"                    
echo "watch curl -v http://${SM_REMOTE_ROUTE}/chain"
sleep 10
watch curl -v http://${SM_REMOTE_ROUTE}/chain

