#!/bin/bash

SM_CP_NS=$1
SM_TENANT_NAME=tenant-1
SM_MR_NS_1=$2
SM_MR_NS_2=$3
REMOTE_SERVICE_ROUTE_NAME=$4 #eg. hello.remote.com


echo '---------------------------------------------------------------------------'
echo 'ServiceMesh Control Plane Namespace        : '$SM_CP_NS
echo 'ServiceMesh Control Plane Tenant Name      : '$SM_TENANT_NAME
echo 'ServiceMesh Member Namespace               : '$SM_MR_NS_1
echo 'rest-greeting-remote Namespace             : '$SM_MR_NS_2
echo 'Remote Service Route                       : '$REMOTE_SERVICE_ROUTE_NAME
echo '---------------------------------------------------------------------------'

echo
echo "#############################################################################"
echo "#		Create client Mesh [$SM_CP_NS]                                    #"
echo "#############################################################################"
echo 
oc new-project $SM_CP_NS
oc apply -f smcp-2.1.1-allow_any-auto-mtls.yaml -n $SM_CP_NS
echo
sleep 10


echo "################## Deploy rest-client-greeting [$SM_MR_NS_1] #########################"
cd ../coded-services/quarkus-rest-client-greeting
oc new-project $SM_MR_NS_1
oc project  $SM_MR_NS_1

mvn clean package -Dquarkus.kubernetes.deploy=true -DskipTests

sleep 5
oc patch dc/rest-client-greeting -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "true"}}}}}' -n  $SM_MR_NS_1
oc set env dc/rest-client-greeting GREETINGS_SVC_LOCATION="http://${REMOTE_SERVICE_ROUTE_NAME}"  -n  $SM_MR_NS_1

cd ../../Scenario-MTLS-3-SM-Service-To-External-MTLS-Handling

echo
echo "################# SMR [$SM_MR_NS_1] added in SMCP [ns:$SM_CP_NS name: $SM_TENANT_NAME] #################"   
echo "sh  ../scripts/create-membership.sh $SM_CP_NS $SM_TENANT_NAME $SM_MR_NS_1"
sh ../scripts/create-membership.sh $SM_CP_NS $SM_TENANT_NAME $SM_MR_NS_1

sleep 15
echo "oc rollout latest dc/rest-client-greeting  -n  $SM_MR_NS_1"
oc rollout latest dc/rest-client-greeting  -n  $SM_MR_NS_1    

echo 
echo "#############################################################################"
echo "#		INCOMING TRAFFIC SM CONFIGS                                       #"
echo "#############################################################################"
echo 
echo "################# Gateway - rest-client-gateway [$SM_MR_NS_1] #################"
echo "apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: rest-client-gateway
spec:
  selector:
    istio: ingressgateway # use istio default controller
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - '*'" | oc apply -n $SM_MR_NS_1 -f -    

echo "################# VirtualService - rest-client-greeting [$SM_MR_NS_1] #################"
echo "apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: rest-client-greeting
spec:
  hosts:
  - '*'
  gateways:
  - rest-client-gateway
  http:
  - match:
    - uri:
        prefix: /say
    route:
    - destination:
        host: rest-client-greeting
        port:
          number: 8080  " | oc apply -n $SM_MR_NS_1 -f -     


echo
echo "#############################################################################"
echo "#		Deploy rest-greeting-remote [$SM_MR_NS_2]                         #"
echo "#############################################################################"
echo 
cd ../coded-services/quarkus-rest-greeting-remote
oc new-project $SM_MR_NS_2
oc project  $SM_MR_NS_2

mvn clean package -Dquarkus.kubernetes.deploy=true -DskipTests
   
sleep 10   
   
echo
echo "#############################################################################"
echo "#		Testing                                                           #"
echo "#############################################################################"
echo 
watch curl -X GET http://$(oc get route istio-ingressgateway -o jsonpath='{.spec.host}' -n $SM_CP_NS)/say/goodday-to/Stelios
