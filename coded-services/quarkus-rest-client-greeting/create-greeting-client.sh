#!/bin/bash

SM_CP_NS=$1
SM_MR_NS=$2
SM_CLIENT_ROUTE=$3
SM_REMOTE_1_ROUTE=$4
SM_REMOTE_2_ROUTE=$5
REMOTE_SERVICE_ROUTE=$6	#eg. hello.remote.com

# istio-ingressgateway-istio-system-tenant-5x.apps.cluster-vnm7p.vnm7p.sandbox1792.opentlc.com istio-ingressgateway-istio-system-tenant-5x.apps.cluster-ac6a.ac6a.sandbox1173.opentlc.com istio-ingressgateway-istio-system-tenant-5x.apps.rosa-e532.qxhy.p1.openshiftapps.com

echo 'ServiceMesh Namespace                        : '$SM_CP_NS
echo 'ServiceMesh Member Namespace                 : '$SM_MR_NS
echo 'ServiceMesh (Client) Ingress Gateway Route   : '$SM_CLIENT_ROUTE	
echo 'ServiceMesh (Remote 1) Ingress Gateway Route : '$SM_REMOTE_1_ROUTE	
echo 'ServiceMesh (Remote 2) Ingress Gateway Route : '$SM_REMOTE_2_ROUTE	
echo 'Remote Greeting Service Route                : '$REMOTE_SERVICE_ROUTE	

#oc new-project $SM_MR_NS
oc project $SM_MR_NS

mvn clean package -Dquarkus.kubernetes.deploy=true -DskipTests

oc patch dc/rest-client-greeting -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "true"}}}}}' -n  $SM_MR_NS
oc set env dc/rest-client-greeting GREETINGS_SVC_LOCATION="http://${REMOTE_SERVICE_ROUTE}"  -n  $SM_MR_NS
#oc patch dc/rest-client-greeting -p '{"spec":{"template":{"spec":{"containers":[{"name":"rest-client-greeting","hostAliases":[{"ip":"127.0.0.1"},{"hostnames":["hello2.client.com"]}]}]}}}}'  -n  $SM_MR_NS
#oc patch dc/rest-client-greeting -p '{"spec":{"template":{"spec":{"containers":[{"name":"rest-client-greeting","hostAliases":[{"ip":"10.1.2.3"},{"hostnames":["hello2.remote.com"]}]}]}}}}'  -n  $SM_MR_NS
echo 'sleeping 15s'
sleep 15
oc rollout latest dc/rest-client-greeting  -n  $SM_MR_NS            


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
                                       
   
echo "################# ServiceEntry - remote-getting-started [$SM_CP_NS] #################"    
echo "kind: ServiceEntry
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: remote-getting-started
spec:
  hosts:
    - ${REMOTE_SERVICE_ROUTE}
  ports:
    - name: http
      number: 80
      protocol: HTTP
  location: MESH_EXTERNAL
  resolution: DNS
  endpoints:
    - address: >-
        ${SM_REMOTE_1_ROUTE}
      labels:
        cluster: primary
      locality: primary
      ports:
        http: 80
      weight: 100        
    - address: >-
        ${SM_REMOTE_2_ROUTE}
      labels:
        cluster: secondary
      locality: secondary
      ports:
        http: 80" | oc apply -n $SM_CP_NS -f -            

echo "################# DestinationRule - egress-for-target-subset-failover-destination-rule [$SM_CP_NS] #################"    
echo "kind: DestinationRule
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: egress-for-target-subset-failover-destination-rule
spec:
  host: ${REMOTE_SERVICE_ROUTE}
  trafficPolicy:
    connectionPool:
      http:
        http1MaxPendingRequests: 5
        http2MaxRequests: 5
        maxRetries: 5
  subsets:
    - name: target-subset
      trafficPolicy:
        loadBalancer:
          localityLbSetting:
            enabled: true
            failover:
              - from: primary
                to: secondary
        outlierDetection:
          baseEjectionTime: 1m
          consecutiveErrors: 3
          interval: 10s" | oc apply -n $SM_CP_NS -f -    
          
#echo "kind: DestinationRule
#apiVersion: networking.istio.io/v1alpha3
#metadata:
#  name: egress-for-target-subset-failover-destination-rule
#spec:
#  host: ${REMOTE_SERVICE_ROUTE}
#  trafficPolicy:
#    connectionPool:
#      http:
#        http1MaxPendingRequests: 5
#        http2MaxRequests: 5
#        maxRetries: 5
#  subsets:
#    - name: target-subset
#      trafficPolicy:
#        loadBalancer:
#          localityLbSetting:
#            enabled: true
#            distribute:
#              - from: primary
#                to:
#                  primary: 95
#                  secondary: 5
#        outlierDetection:
#          baseEjectionTime: 1m
#          consecutiveErrors: 3
#          interval: 10s" | oc apply -n $SM_CP_NS -f -              

echo "################# Gateway - istio-egressgateway [$SM_CP_NS] #################"    
echo "kind: Gateway
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: istio-egressgateway
spec:
  servers:
    - hosts:
        - '*'
      port:
        name: http
        number: 80
        protocol: HTTP
  selector:
    istio: egressgateway" | oc apply -n $SM_CP_NS -f -    

echo "################# VirtualService - gateway-routing [$SM_CP_NS] #################"    
echo "kind: VirtualService
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: gateway-routing
spec:
  hosts:
    - ${REMOTE_SERVICE_ROUTE}
  gateways:
    - mesh
    - istio-egressgateway
  http:
    - match:
        - gateways:
            - mesh
          port: 80
      route:
        - destination:
            host: istio-egressgateway.${SM_CP_NS}.svc.cluster.local
    - match:
        - gateways:
            - istio-egressgateway
          port: 80
      route:
        - destination:
            host: ${REMOTE_SERVICE_ROUTE}
            subset: target-subset
          weight: 100
  exportTo:
    - '*'  " | oc apply -n $SM_CP_NS -f -    

echo ''
echo ''
echo ''
echo ''
echo "###########################################################################"
echo "#                                                                         #"
echo "# If ${REMOTE_SERVICE_ROUTE} no DNS resolution edit dc/rest-client-greeting      #"
echo "# addint to container 'rest-greeting-remote'                              #"
echo "#                                                                         #"
echo "#                                                                         #"
echo "       hostAliases:		"
echo "        - ip: 127.0.0.1			"
echo "          hostnames:			"
echo "            - hello.client.com		"
echo "        - ip: 10.1.2.3			"
echo "          hostnames:			"
echo "            - ${REMOTE_SERVICE_ROUTE}		"
echo "#                                                                         #"
echo "# oc rollout latest dc/rest-client-greeting  -n  $SM_MR_NS                #"
echo "###########################################################################"





          
          
          
          
          
          
          
              
