#!/bin/bash

SM_CP_NS=$1
SM_MR_NS=$2
SM_REMOTE_ROUTE=$3
#eg. hello.remote.com
REMOTE_SERVICE_ROUTE=$4
CLUSTER_NAME=$5

echo 'ServiceMesh Namespace                      : '$SM_CP_NS
echo 'ServiceMesh Member Namespace               : '$SM_MR_NS
echo 'ServiceMesh (Remote) Ingress Gateway Route : '$SM_REMOTE_ROUTE	
echo 'Remote Cluster Name                        : '$CLUSTER_NAME
echo 'Remote Service Route                       : '$REMOTE_SERVICE_ROUTE

cd ../coded-services/quarkus-rest-greeting-remote
oc new-project $SM_MR_NS
oc project  $SM_MR_NS

mvn clean package -Dquarkus.kubernetes.deploy=true -DskipTests

oc patch dc/rest-greeting-remote -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "true"}}}}}' -n  $SM_MR_NS
oc set env dc/rest-greeting-remote GREETINGS_SVC_LOCATION=$REMOTE_SERVICE_ROUTE -n  $SM_MR_NS
oc set env dc/rest-greeting-remote GREETING_LOCATION=$CLUSTER_NAME -n  $SM_MR_NS
echo 'sleeping 15s'
sleep 15
oc rollout latest dc/rest-greeting-remote  -n  $SM_MR_NS

   
echo "################# Route - hello-remote [$SM_CP_NS] #################"   
echo "kind: Route
apiVersion: route.openshift.io/v1
metadata:
  name: hello-remote
spec:
  host: ${REMOTE_SERVICE_ROUTE}
  to:
    kind: Service
    name: istio-ingressgateway
    weight: 100
  port:
    targetPort: http2
  wildcardPolicy: None" | oc apply -n $SM_CP_NS -f -  
  
echo "################# Gateway - rest-greeting-remote-gateway [$SM_MR_NS] #################"     
echo "apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: rest-greeting-remote-gateway
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
    - ${REMOTE_SERVICE_ROUTE} " | oc apply -n $SM_MR_NS -f -  

echo "################# VirtualService - rest-greeting-remote [$SM_MR_NS] #################"     
echo "apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: rest-greeting-remote
spec:
  hosts:
  - ${SM_REMOTE_ROUTE}
  - ${REMOTE_SERVICE_ROUTE} 
  gateways:
  - rest-greeting-remote-gateway
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
          number: 8080     " | oc apply -n $SM_MR_NS -f -  
  
  
  
    
