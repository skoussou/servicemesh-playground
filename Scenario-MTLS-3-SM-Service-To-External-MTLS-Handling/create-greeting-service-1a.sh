#!/bin/bash

SM_CP_NS=$1
SM_TENANT_NAME=$2
SM_MR_NS=$3
#SM_MR_RESOURCE_NAME=$4
REMOTE_SERVICE_ROUTE=$4 #eg. hello.remote.com
CERTIFICATE_SECRET_NAME=$5
CLUSTER_NAME=$6

echo '---------------------------------------------------------------------------'
echo 'ServiceMesh Namespace                      : '$SM_CP_NS
echo 'ServiceMesh Control Plane Tenant Name      : '$SM_TENANT_NAME
echo 'ServiceMesh Member Namespace               : '$SM_MR_NS
#echo 'ServiceMeshMember Resource Name            : '$SM_MR_RESOURCE_NAME
#echo 'ServiceMesh (Remote) Ingress Gateway Route : '$SM_REMOTE_ROUTE	
echo 'Remote Cluster Name                        : '$CLUSTER_NAME
echo 'Remote Service Route                       : '$REMOTE_SERVICE_ROUTE
echo 'Greting Service Route Cert Secret Name     : '$CERTIFICATE_SECRET_NAME
echo '---------------------------------------------------------------------------'

cd ../coded-services/quarkus-rest-greeting-remote
oc new-project $SM_MR_NS
oc project  $SM_MR_NS

mvn clean package -Dquarkus.kubernetes.deploy=true -DskipTests

#echo 'sleeping 15s'
sleep 15
oc patch dc/rest-greeting-remote -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "true"}}}}}' -n  $SM_MR_NS
oc set env dc/rest-greeting-remote GREETINGS_SVC_LOCATION=$REMOTE_SERVICE_ROUTE -n  $SM_MR_NS
oc set env dc/rest-greeting-remote GREETING_LOCATION=$CLUSTER_NAME -n  $SM_MR_NS

cd ../../Scenario-MTLS-3-SM-Service-To-External-MTLS-Handling
echo
echo "################# SMR [$SM_MR_RESOURCE_NAME] added in SMCP [ns:$SM_CP_NS name: $SM_TENANT_NAME] #################"   
echo "sh  ./create-membership.sh $SM_CP_NS $SM_TENANT_NAME $SM_MR_NS"
sh create-membership.sh $SM_CP_NS $SM_TENANT_NAME $SM_MR_NS

echo
echo "oc rollout latest dc/rest-greeting-remote  -n  $SM_MR_NS"
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
    targetPort: https
  tls:
    termination: passthrough    
  wildcardPolicy: None" | oc apply -n $SM_CP_NS -f -  
  
echo "################# Gateway - rest-greeting-remote-gateway [$SM_MR_NS] #################"     

echo "apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: rest-greeting-remote-gateway
spec:
  selector:
    istio: ingressgateway # use istio default gateway service
  servers:
  - port:
      number: 8443
      name: https
      protocol: HTTPS
    tls:
      credentialName: $CERTIFICATE_SECRET_NAME #eg. greeting-remote-secret
      mode: SIMPLE
    hosts: 
    - $REMOTE_SERVICE_ROUTE" | oc apply -n $SM_MR_NS -f -  

echo "################# VirtualService - rest-greeting-remote [$SM_MR_NS] #################"     


echo "apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: rest-greeting-remote
spec:
  hosts:
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
