#!/bin/bash

SM_CP_NS=$1
SM_TENANT_NAME=$2
SM_MR_NS=$3
SM_MR_RESOURCE_NAME=$4
REMOTE_SERVICE_ROUTE_NAME=$5 #eg. hello.remote.com
SM_REMOTE_ROUTE_LOCATION=$6 #eg. in absence of DNS remote istio-ingressgateway route's url
CERTIFICATE_SECRET_NAME=$7


echo '---------------------------------------------------------------------------'
echo 'ServiceMesh Control Plane Namespace        : '$SM_CP_NS
echo 'ServiceMesh Control Plane Tenant Name      : '$SM_TENANT_NAME
echo 'ServiceMesh Member Namespace               : '$SM_MR_NS
echo 'ServiceMeshMember Resource Name            : '$SM_MR_RESOURCE_NAME
#echo 'ServiceMesh (Remote) Ingress Gateway Route : '$SM_REMOTE_ROUTE	
echo 'Remote Service Route                       : '$REMOTE_SERVICE_ROUTE_NAME
echo 'Remote SMCP Route Name (when NO DNS)       : '$SM_REMOTE_ROUTE_LOCATION
echo 'Greting Service Route Cert Secret Name     : '$CERTIFICATE_SECRET_NAME
echo '---------------------------------------------------------------------------'

cd ../coded-services/quarkus-rest-client-greeting
oc new-project $SM_MR_NS
oc project  $SM_MR_NS

mvn clean package -Dquarkus.kubernetes.deploy=true -DskipTests

sleep 15
oc patch dc/rest-client-greeting -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "true"}}}}}' -n  $SM_MR_NS
oc set env dc/rest-client-greeting GREETINGS_SVC_LOCATION="https://${REMOTE_SERVICE_ROUTE_NAME}"  -n  $SM_MR_NS
oc set env dc/rest-client-greeting GREETINGS_SVC_LOCATION="https://greeting.remote.com"  -n  greetings-client-2
echo ""
echo "Patch dc/rest-client-greeting to resolve route hostname [$REMOTE_SERVICE_ROUTE_NAME]"
echo "----------------------------------------------------------------------------------"
#echo "oc patch dc/rest-client-greeting -p '{"spec":{"template":{"spec":{"containers":[{"name":"rest-client-greeting","hostAliases":[{"ip":"127.0.0.1"},{"hostnames":["$REMOTE_SERVICE_ROUTE_NAME"]}]}]}}}}'  -n  $SM_MR_NS"
#echo "oc patch dc/rest-client-greeting -p '{"spec":{"template":{"spec":{"hostAliases":[{"ip":"10.1.2.3","hostnames":["$REMOTE_SERVICE_ROUTE_NAME"]}]}}}}'  -n  $SM_MR_NS"
#echo "oc patch dc/rest-client-greeting -p '{"spec":{"template":{"spec":{"hostAliases":[{"ip":"10.1.2.3","hostnames":["greeting.remote.com"]}]}}}}'  -n greetings-client-2"

#working oc patch dc/rest-client-greeting -p '{"spec":{"template":{"spec":{"hostAliases":[{"ip":"127.0.0.1","hostnames":["greeting.remote.com"]}]}}}}'  -n greetings-client-2
echo "oc patch dc/rest-client-greeting -p '{"spec":{"template":{"spec":{"hostAliases":[{"ip":"127.0.0.1","hostnames":["$REMOTE_SERVICE_ROUTE_NAME"]}]}}}}'  -n $SM_MR_NS"
oc patch dc/rest-client-greeting -p '{"spec":{"template":{"spec":{"hostAliases":[{"ip":"127.0.0.1","hostnames":["$REMOTE_SERVICE_ROUTE_NAME"]}]}}}}'  -n $SM_MR_NS
            
#oc patch dc/rest-client-greeting -p '{"spec":{"template":{"spec":{"containers":[{"name":"rest-client-greeting","hostAliases":[{"ip":"127.0.0.1"},{"hostnames":["$REMOTE_SERVICE_ROUTE_NAME"]}]}]}}}}'  -n  $SM_MR_NS
#oc patch dc/rest-client-greeting -p '{"spec":{"template":{"spec":{"containers":[{"name":"rest-client-greeting","hostAliases":[{"ip":"10.1.2.3"},{"hostnames":["hello2.remote.com"]}]}]}}}}'  -n  $SM_MR_NS
sleep 5
oc rollout latest dc/rest-client-greeting  -n  $SM_MR_NS      

echo "################# SMR [$SM_MR_RESOURCE_NAME] added in SMCP [ns:$SM_CP_NS name: $SM_TENANT_NAME] #################"   
sh ./create-membership.sh $SM_MR_RESOURCE_NAME $SM_TENANT_NAME $SM_MR_NS
   
echo "################# Gateway - rest-client-gateway [$SM_MR_NS] #################"
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
    - '*'" | oc apply -n $SM_MR_NS -f -    

echo "################# VirtualService - rest-client-greeting [$SM_MR_NS] #################"
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
          number: 8080  " | oc apply -n $SM_MR_NS -f -     
          
echo "################# ServiceEntry - rest-greeting-remote-mesh-ext [$SM_CP_NS] #################"    
echo "kind: ServiceEntry
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: rest-greeting-remote-mesh-ext
spec:
  hosts:
    - ${REMOTE_SERVICE_ROUTE}
  ports:
    - name: http
      number: 443
      protocol: HTTP
  location: MESH_EXTERNAL
  resolution: DNS
  endpoints:
    - address: >-
        ${SM_REMOTE_ROUTE_LOCATION}
      ports:
        http: 443
      weight: 100" | oc apply -n $SM_CP_NS -f -            
          
echo "################# DestinationRule - originate-tls-to-rest-greeting-remote-destination-rule [$SM_CP_NS] #################"    
echo "kind: DestinationRule
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: originate-tls-to-rest-greeting-remote
spec:
  host: ${REMOTE_SERVICE_ROUTE}
  trafficPolicy:
    tls:
      mode: SIMPLE" | oc apply -n $SM_CP_NS -f -           
          
          
# BELOW HERE EXAMPLE 1B1          
#echo "################# Gateway - istio-egressgateway [$SM_CP_NS] #################"    
#echo "kind: Gateway
#apiVersion: networking.istio.io/v1alpha3
#metadata:
#  name: istio-egressgateway
#spec:
#  servers:
#    - hosts:
#        - '*'
#      port:
#        name: http
#        number: 80
#        protocol: HTTP
#  selector:
#    istio: egressgateway" | oc apply -n $SM_CP_NS -f -    

#echo "################# VirtualService - gateway-routing [$SM_CP_NS] #################"    
#echo "kind: VirtualService
#apiVersion: networking.istio.io/v1alpha3
#metadata:
#  name: gateway-routing
#spec:
#  hosts:
#    - ${REMOTE_SERVICE_ROUTE}
#  gateways:
#    - mesh
#    - istio-egressgateway
#  http:
#    - match:
#        - gateways:
#            - mesh
#          port: 80
#      route:
#        - destination:
#            host: istio-egressgateway.${SM_CP_NS}.svc.cluster.local
#    - match:
#        - gateways:
#            - istio-egressgateway
#          port: 80
#      route:
#        - destination:
#            host: ${REMOTE_SERVICE_ROUTE}
#            subset: target-subset
#          weight: 100
#  exportTo:
#    - '*'  " | oc apply -n $SM_CP_NS -f -          
          
          
          
          
          
          
          
          
          
          
          
          
          
