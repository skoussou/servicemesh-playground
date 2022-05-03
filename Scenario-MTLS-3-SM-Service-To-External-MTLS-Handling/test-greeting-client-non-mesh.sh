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
echo ' Create NON-Istio Based Client'
echo '------------------------------------------------------------------------------------------------'
echo 
echo ' Step 1 - ServiceMeshControlPlane: rest-client-greeting (greetings-client-nonmesh)'
echo  

oc new-project greetings-client-nonmesh
sleep 2
cd ../coded-services/quarkus-rest-client-greeting
oc project greetings-client-nonmesh
mvn clean package -Dquarkus.kubernetes.deploy=true -DskipTests 
# Cannot use this unless I either validate ISTIO's certs or ignore oc set env dc/rest-client-greeting GREETINGS_SVC_LOCATION="https://istio-ingressgateway.istio-system-service.svc.cluster.local:443"  -n  greetings-client-nonmesh
# https://istio-ingressgateway.istio-system-service.svc.cluster.local:443/hello
sleep 7
oc set env dc/rest-client-greeting GREETINGS_SVC_LOCATION="http://istio-ingressgateway.istio-system-service.svc.cluster.local:80"  -n  greetings-client-nonmesh
sleep 7
oc rollout latest dc/rest-client-greeting  -n  greetings-client-nonmesh  

sleep 2
oc expose svc rest-client-greeting

sleep 2

echo 
echo ' Step 2 - Test non-mesh rest-client-greeting'
echo  

watch curl -i http://$(oc get route rest-client-greeting -o jsonpath='{.spec.host}' -n greetings-client-nonmesh)/say/goodday-to/Stelios
