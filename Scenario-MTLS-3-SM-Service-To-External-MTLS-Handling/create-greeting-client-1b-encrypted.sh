#!/bin/bash

SM_CP_NS=$1
SM_TENANT_NAME=$2
SM_MR_NS=$3
#SM_MR_RESOURCE_NAME=$4
REMOTE_SERVICE_ROUTE_NAME=$4 #eg. hello.remote.com
#SM_REMOTE_ROUTE_LOCATION=$5 #eg. in absence of DNS remote istio-ingressgateway route's url
CERTIFICATE_SECRET_NAME=$5


echo '---------------------------------------------------------------------------'
echo 'ServiceMesh Control Plane Namespace        : '$SM_CP_NS
echo 'ServiceMesh Control Plane Tenant Name      : '$SM_TENANT_NAME
echo 'ServiceMesh Member Namespace               : '$SM_MR_NS
#echo 'ServiceMeshMember Resource Name            : '$SM_MR_RESOURCE_NAME
#echo 'ServiceMesh (Remote) Ingress Gateway Route : '$SM_REMOTE_ROUTE	
echo 'Remote Service Route                       : '$REMOTE_SERVICE_ROUTE_NAME
#echo 'Remote SMCP Route Name (when NO DNS)       : '$SM_REMOTE_ROUTE_LOCATION
echo 'Greting Service Route Cert Secret Name     : '$CERTIFICATE_SECRET_NAME
echo '---------------------------------------------------------------------------'

cd ../coded-services/quarkus-rest-client-greeting
oc new-project $SM_MR_NS
oc project  $SM_MR_NS

mvn clean package -Dquarkus.kubernetes.deploy=true -DskipTests

#sleep 15
oc patch dc/rest-client-greeting -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "true"}}}}}' -n  $SM_MR_NS
# #READ first
# this https://istio.io/latest/docs/reference/config/networking/destination-rule/#ClientTLSSettings (credentialName field is currently applicable only at gateways. Sidecars will continue to use the certificate paths.) and 
# then this https://zufardhiyaulhaq.com/Istio-mutual-TLS-between-clusters/
# https://support.f5.com/csp/article/K29450727
#oc patch dc/rest-client-greeting -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/userVolumeMount": "[{\"name\": \"greeting-client-secret\", \"mountPath\": \"/etc/certs\", \"readonly\": true}]" }}}}}' -n  $SM_MR_NS
#oc patch dc/rest-client-greeting -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/userVolume": "[{\"name\":\"greeting-client-secret\", \"secret\":{\"secretName\":\"greeting-client-secret\"}}]" }}}}}' -n  $SM_MR_NS 
#POD MUST SEND TO NON HTTPS SO DR BELOW WILL CHANGE TO HTTPS
oc set env dc/rest-client-greeting GREETINGS_SVC_LOCATION="http://${REMOTE_SERVICE_ROUTE_NAME}"  -n  $SM_MR_NS
#oc set env dc/rest-client-greeting GREETINGS_SVC_LOCATION="https://greeting.remote.com"  -n  greetings-client-2

# Due to mutual TLS needs a public DNS hostname is required for the certificate. Therefore although valid the following is commented out
#echo ""
#echo "Patch dc/rest-client-greeting to resolve route hostname [$REMOTE_SERVICE_ROUTE_NAME]"
#echo "----------------------------------------------------------------------------------"
#echo "oc patch dc/rest-client-greeting -p '{"spec":{"template":{"spec":{"hostAliases":[{"ip":"10.1.2.3","hostnames":["$REMOTE_SERVICE_ROUTE_NAME"]}]}}}}'  -n $SM_MR_NS"
#oc patch dc/rest-client-greeting -p '{"spec":{"template":{"spec":{"hostAliases":[{"ip":"10.1.2.3","hostnames":["'$REMOTE_SERVICE_ROUTE_NAME'"]}]}}}}'  -n $SM_MR_NS
  
cd ../../Scenario-MTLS-3-SM-Service-To-External-MTLS-Handling
echo
echo "################# SMR [$SM_MR_NS] added in SMCP [ns:$SM_CP_NS name: $SM_TENANT_NAME] #################"   
echo "sh  ../scripts/create-membership.sh $SM_CP_NS $SM_TENANT_NAME $SM_MR_NS"
sh ../scripts/create-membership.sh $SM_CP_NS $SM_TENANT_NAME $SM_MR_NS

sleep 15
echo "oc rollout latest dc/rest-client-greeting  -n  $SM_MR_NS"
oc rollout latest dc/rest-client-greeting  -n  $SM_MR_NS    
   
echo 
echo "#############################################################################"
echo "#		INCOMING TRAFFIC SM CONFIGS                                       #"
echo "#############################################################################"
echo 
echo "################# Gateway - rest-client-gateway [$SM_CP_NS] #################"
echo "apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: rest-client-gateway
  namespace: $SM_CP_NS
spec:
  selector:
    istio: ingressgateway # use istio default controller
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - '*'" | oc apply -f -    

echo
echo "################# VirtualService - rest-client-greeting [$SM_MR_NS] #################"
echo "apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: rest-client-greeting
  namespace: $SM_MR_NS  
spec:
  hosts:
  - '*'
  gateways:
  - $SM_CP_NS/rest-client-gateway
  http:
  - match:
    - uri:
        prefix: /say
    route:
    - destination:
        host: rest-client-greeting
        port:
          number: 8080  
  exportTo:
  - '.'
  - $SM_CP_NS" | oc apply -f -     


echo 
echo "#############################################################################"
echo "#		OUTGOING TRAFFIC SM CONFIGS                                        #"
echo "#############################################################################"
echo           
echo "################# ServiceEntry - rest-greeting-remote-mesh-ext [$SM_MR_NS] #################"    
echo "kind: ServiceEntry
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: rest-greeting-remote-mesh-ext
  namespace: $SM_MR_NS
spec:
  hosts:
    - ${REMOTE_SERVICE_ROUTE_NAME}
  addresses: ~
  ports:
    - name: http
      number: 443
      protocol: HTTP2
  location: MESH_EXTERNAL
  resolution: DNS
  exportTo:
  - '*'" | oc apply -f -    
  
 
# BELOW HERE EXAMPLE 1B1  

echo
echo "########## DIRECT Requests to Egress Gateway ################################"
echo    
# 1. Create an egress Gateway for my-nginx.mesh-external.svc.cluster.local, port 443,  
echo "################# Gateway - rest-greeting-remote-mtls-gateway [$SM_CP_NS] #################"      
echo "apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: istio-egressgateway
  namespace: $SM_CP_NS  
spec:
  selector:
    istio: egressgateway
  servers:
  - port:
      number: 443
      name: https
      protocol: HTTPS
    hosts:
    - ${REMOTE_SERVICE_ROUTE_NAME}
    tls:
      mode: ISTIO_MUTUAL" | oc apply -f -             
  
echo  
# 2. destination rules and virtual services to direct the traffic through the egress gateway and from the egress gateway to the external service.       
echo "################# DestinationRule - egress-originate-tls-to-rest-greeting-remote-destination-rule [$SM_MR_NS] #################"    
echo "kind: DestinationRule
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: egress-originate-tls-to-rest-greeting-remote
  namespace: $SM_MR_NS  
spec:
  host: istio-egressgateway.${SM_CP_NS}.svc.cluster.local
  trafficPolicy:
  subsets:
  - name: greeting-remote
    trafficPolicy:
      loadBalancer:
        simple: ROUND_ROBIN
      portLevelSettings:
      - port:
          number: 443
        tls:
          mode: ISTIO_MUTUAL
          sni: ${REMOTE_SERVICE_ROUTE_NAME}
  exportTo:
  - '.'" | oc apply -f -   
  


echo   
echo "################# VirtualService - route-mesh-gw-to-egress-gw [$SM_MR_NS] #################"        
echo "kind: VirtualService
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: route-mesh-gw-to-egress-gw
  namespace: $SM_MR_NS  
spec:
  hosts:
    - ${REMOTE_SERVICE_ROUTE_NAME}
  gateways:
    - mesh
  http:
    - match:
        - gateways:
            - mesh
          port: 80
      route:
        - destination:
            host: istio-egressgateway.${SM_CP_NS}.svc.cluster.local
            port:
              number: 443
            subset: greeting-remote
          weight: 100
  exportTo:
    - ." | oc apply -f -   


echo   
echo "################# VirtualService - route-egress-gw-to-ext [$SM_CP_NS] #################"        
echo "kind: VirtualService
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: route-egress-gw-to-ext
  namespace: $SM_CP_NS  
spec:
  hosts:
    - ${REMOTE_SERVICE_ROUTE_NAME}
  gateways:
    - istio-egressgateway
  http:
    - match:
        - gateways:
            - istio-egressgateway
          port: 443
      route:
        - destination:
            host: ${REMOTE_SERVICE_ROUTE_NAME}
            port:
              number: 443
          weight: 100
  exportTo:
    - ." | oc apply -f -  


echo
echo "########## Egress Gateway - TLS Origination ################################"
echo    


# 3. Add a DestinationRule to perform mutual TLS origination
echo "################# DestinationRule - originate-mtls-for-greeting-remote [$SM_CP_NS] #################"      
echo "apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: originate-mtls-for-greeting-remote
  namespace: $SM_CP_NS    
spec:
  host: ${REMOTE_SERVICE_ROUTE_NAME}
  trafficPolicy:
    loadBalancer:
      simple: ROUND_ROBIN
    portLevelSettings:
    - port:
        number: 443
      tls:
        mode: MUTUAL
        credentialName: ${CERTIFICATE_SECRET_NAME}
        sni: ${REMOTE_SERVICE_ROUTE_NAME} 
  exportTo:
  - '.'"        | oc apply -f -    

sleep 15
echo   
echo "################# Testing against Host [$(oc get route istio-ingressgateway -o jsonpath='{.spec.host}' -n istio-system-egressgw-mtls-client)]  #################"        
echo 
watch curl -X GET http://$(oc get route istio-ingressgateway -o jsonpath='{.spec.host}' -n istio-system-egressgw-mtls-client)/say/goodday-to/Stelios



# WORKING CONFIGS FROM APP NAMESPACE          
#working-app-names-ace-egress-mtls-setup.yaml    

# WORKING CONFIGS FROM BOTH APP and ISTIO-SYSTEM NAMESPACE                
          

