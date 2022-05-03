#!/bin/bash

echo 'PREREQUISITE -----------------------------------------------------------------------------------'
echo 'PREREQUISITE                                                                                    '
echo 'PREREQUISITE  The scenario MTLS-3 (Option 1a: directly (via Sidecar)) must have been run first  '
echo 'PREREQUISITE                                                                                    '
echo 'PREREQUISITE -----------------------------------------------------------------------------------'
echo
echo
echo '------------------------------------------------------------------------------------------------'
echo ' SETUP IN CLUSTER NON-TLS ACCESS towards rest-greeting-remote (greetings-service)'
echo '------------------------------------------------------------------------------------------------'

#Scenario-MTLS-3-SM-Service-To-External-MTLS-Handling

echo "kind: Gateway
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: in-cluster-rest-greeting-remote-gateway
  namespace: greetings-service
spec:
  servers:
    - hosts:
        - 'istio-ingressgateway.istio-system-service.svc.cluster.local'
      port:
        name: http-web
        number: 80
        protocol: HTTP
  selector:
    istio: ingressgateway" |oc apply -f -
    
echo "kind: VirtualService
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: in-cluster-rest-greeting-remote
  namespace: greetings-service
spec:
  hosts:
    - 'istio-ingressgateway.istio-system-service.svc.cluster.local'
  gateways:
    - in-cluster-rest-greeting-remote-gateway
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
              number: 8080" |oc apply -f -

echo 
echo ' Create Istio Based Client with ALLOW_ANY mesh oubound networking policy'
echo '------------------------------------------------------------------------------------------------'
echo 
echo ' Step 1 - ServiceMeshControlPlane: tenant-allow-any (ALLOW_ANY)'
echo  
oc new-project istio-system-client-allow-any

sleep 2

echo "apiVersion: maistra.io/v2
kind: ServiceMeshControlPlane
metadata:
  name: tenant-allow-any
spec:
  tracing:
    sampling: 10000
    type: Jaeger
  general:
    logging:
      logAsJSON: true
  profiles:
    - default
  proxy:
    accessLogging:
      file:
        name: /dev/stdout
    networking:
      trafficControl:
        inbound: {}
        outbound:
          policy: ALLOW_ANY        
  policy:
    type: Istiod
  addons:
    grafana:
      enabled: true
    jaeger:
      install:
        storage:
          type: Memory
    kiali:
      enabled: true
    prometheus:
      enabled: true
  version: v2.1
  telemetry:
    type: Istiod" |oc apply -n istio-system-client-allow-any -f -
 
sleep 5 
 
echo 
echo ' Step 2 - rest-client-greeting (greetings-client-allow-any)'
echo 
oc new-project greetings-client-allow-any 
sleep 2  
cd ../coded-services/quarkus-rest-client-greeting   
../../scripts/create-membership.sh istio-system-client-allow-any tenant-allow-any greetings-client-allow-any
sleep 5
oc project greetings-client-allow-any
mvn clean package -Dquarkus.kubernetes.deploy=true -DskipTests    
oc patch dc/rest-client-greeting -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "true"}}}}}' -n  greetings-client-allow-any   
oc set env dc/rest-client-greeting GREETINGS_SVC_LOCATION="http://istio-ingressgateway.istio-system-service.svc.cluster.local:80"  -n  greetings-client-allow-any   
sleep 15         
oc rollout latest dc/rest-client-greeting  -n  greetings-client-allow-any 
sleep 10
echo 
echo ' Step 3 - Expose rest-client-greeting (greetings-client-allow-any)'
echo 

echo "kind: Gateway
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: rest-client-gateway
  namespace: greetings-client-allow-any
spec:
  servers:
    - hosts:
        - '*'
      port:
        name: http
        number: 80
        protocol: HTTP
  selector:
    istio: ingressgateway" |oc apply -f -
    
echo "kind: VirtualService
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: rest-client-greeting
  namespace: greetings-client-allow-any
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
              number: 8080" |oc apply -f -     

echo 
echo ' Step 4 - Test rest-client-greeting (in ALLOW_ANY)'
echo 

watch curl -i  http://$(oc get route istio-ingressgateway -o jsonpath='{.spec.host}' -n istio-system-client-allow-any)/say/goodday-to/Stelios

echo 
echo ' Step 5 - TURN on REGISTRY_ONLY (failures will start to occur on the client side)'
echo 

echo 
echo ' Step 6 - Apply ServiceEntry to allow via Istio Registry access to external service'
echo 

echo "apiVersion: networking.istio.io/v1beta1
kind: ServiceEntry
metadata:
  name: rest-greeting-remote-mesh-ext
  namespace: greetings-client-allow-any  
spec:
  hosts:
    - istio-ingressgateway.istio-system-service.svc.cluster.local
  location: MESH_EXTERNAL
  ports:
    - name: http
      number: 80
      protocol: HTTP2
  resolution: DNS"

watch curl -i  http://$(oc get route istio-ingressgateway -o jsonpath='{.spec.host}' -n istio-system-client-allow-any)/say/goodday-to/Stelios



