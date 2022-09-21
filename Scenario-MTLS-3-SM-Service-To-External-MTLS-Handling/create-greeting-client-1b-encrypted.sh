#!/bin/bash

SM_CP_NS=$1
SM_TENANT_NAME=$2
SM_MR_NS=$3
REMOTE_SERVICE_ROUTE_NAME=$4 #eg. hello.remote.com
CERTIFICATE_SECRET_NAME=$5


echo '---------------------------------------------------------------------------'
echo 'ServiceMesh Control Plane Namespace        : '$SM_CP_NS
echo 'ServiceMesh Control Plane Tenant Name      : '$SM_TENANT_NAME
echo 'ServiceMesh Member Namespace               : '$SM_MR_NS
echo 'Remote Service Route                       : '$REMOTE_SERVICE_ROUTE_NAME
echo 'Greting Service Route Cert Secret Name     : '$CERTIFICATE_SECRET_NAME
echo '---------------------------------------------------------------------------'

oc new-project $SM_MR_NS
oc project  $SM_MR_NS

echo
echo "################# SMR [$SM_MR_NS] added in SMCP [ns:$SM_CP_NS name: $SM_TENANT_NAME] #################"   
echo "sh  ../scripts/create-membership.sh $SM_CP_NS $SM_TENANT_NAME $SM_MR_NS"
sh ../scripts/create-membership.sh $SM_CP_NS $SM_TENANT_NAME $SM_MR_NS


sleep 15   

echo 
echo '################## Creation of Application [rest-client-greeting] Deployment ##################'
echo "apiVersion: apps/v1
kind: Deployment
metadata:
  name: rest-client-greeting
  namespace: $SM_MR_NS_2
  labels:
    app: rest-client-greeting
    app.kubernetes.io/name: rest-client-greeting
    app.kubernetes.io/version: 1.0.0-SNAPSHOT
    version: v1  
spec:
  selector:
    matchLabels:
      app: rest-client-greeting
      version: v1 
  replicas: 1
  template:
    metadata:
      labels:
        app: rest-client-greeting
        version: v1
      annotations:
        sidecar.istio.io/inject: 'true'        
    spec:
      containers:
        - name: rest-client-greeting
          command:
            - java         
          image: >-
            quay.io/skoussou/rest-client-greeting:1.0.0
          ports:
            - name: http
              containerPort: 8080
              protocol: TCP
          imagePullPolicy: Always              
          env:
            - name: KUBERNETES_NAMESPACE
              valueFrom:
                fieldRef:
                  apiVersion: v1
                  fieldPath: metadata.namespace
            - name: JAVA_LIB_DIR
              value: /deployments/lib
            - name: JAVA_APP_JAR
              value: /deployments/rest-client-greeting-1.0.0-SNAPSHOT-runner.jar
            - name: GREETINGS_SVC_LOCATION
              value: http://$REMOTE_SERVICE_ROUTE_NAME                    
          args:
            - '-jar'
            - /deployments/quarkus-run.jar
            - '-cp'
            - >-
              /deployments/lib/jakarta.annotation.jakarta.annotation-api-1.3.5.jar:/deployments/lib/jakarta.el.jakarta.el-api-3.0.3.jar:/deployments/lib/jakarta.interceptor.jakarta.interceptor-api-1.2.5.jar:/deployments/lib/jakarta.enterprise.jakarta.enterprise.cdi-api-2.0.2.jar:/deployments/lib/jakarta.inject.jakarta.inject-api-1.0.jar:/deployments/lib/io.quarkus.quarkus-development-mode-spi-1.12.0.Final.jar:/deployments/lib/io.smallrye.common.smallrye-common-annotation-1.5.0.jar:/deployments/lib/io.smallrye.config.smallrye-config-common-1.10.2.jar:/deployments/lib/io.smallrye.common.smallrye-common-function-1.5.0.jar:/deployments/lib/io.smallrye.common.smallrye-common-expression-1.5.0.jar:/deployments/lib/io.smallrye.common.smallrye-common-constraint-1.5.0.jar:/deployments/lib/io.smallrye.common.smallrye-common-classloader-1.5.0.jar:/deployments/lib/io.smallrye.config.smallrye-config-1.10.2.jar:/deployments/lib/org.jboss.logging.jboss-logging-3.4.1.Final.jar:/deployments/lib/org.jboss.logmanager.jboss-logmanager-embedded-1.0.6.jar:/deployments/lib/org.jboss.logging.jboss-logging-annotations-2.2.0.Final.jar:/deployments/lib/org.jboss.threads.jboss-threads-3.2.0.Final.jar:/deployments/lib/org.slf4j.slf4j-api-1.7.30.jar:/deployments/lib/org.jboss.slf4j.slf4j-jboss-logmanager-1.1.0.Final.jar:/deployments/lib/org.graalvm.sdk.graal-sdk-21.0.0.jar:/deployments/lib/org.wildfly.common.wildfly-common-1.5.4.Final-format-001.jar:/deployments/lib/io.smallrye.common.smallrye-common-io-1.5.0.jar:/deployments/lib/io.quarkus.quarkus-bootstrap-runner-1.12.0.Final.jar:/deployments/lib/io.quarkus.quarkus-core-1.12.0.Final.jar:/deployments/lib/io.quarkus.quarkus-security-runtime-spi-1.12.0.Final.jar:/deployments/lib/jakarta.transaction.jakarta.transaction-api-1.3.3.jar:/deployments/lib/io.quarkus.arc.arc-1.12.0.Final.jar:/deployments/lib/io.quarkus.quarkus-vertx-http-dev-console-runtime-spi-1.12.0.Final.jar:/deployments/lib/org.reactivestreams.reactive-streams-1.0.3.jar:/deployments/lib/io.smallrye.reactive.mutiny-0.13.0.jar:/deployments/lib/io.quarkus.security.quarkus-security-1.1.3.Final.jar:/deployments/lib/io.netty.netty-codec-4.1.49.Final.jar:/deployments/lib/io.netty.netty-handler-4.1.49.Final.jar:/deployments/lib/io.quarkus.quarkus-netty-1.12.0.Final.jar:/deployments/lib/io.netty.netty-common-4.1.49.Final.jar:/deployments/lib/io.netty.netty-buffer-4.1.49.Final.jar:/deployments/lib/io.netty.netty-transport-4.1.49.Final.jar:/deployments/lib/io.netty.netty-codec-socks-4.1.49.Final.jar:/deployments/lib/io.netty.netty-handler-proxy-4.1.49.Final.jar:/deployments/lib/io.netty.netty-codec-http-4.1.49.Final.jar:/deployments/lib/io.netty.netty-codec-http2-4.1.49.Final.jar:/deployments/lib/io.netty.netty-resolver-4.1.49.Final.jar:/deployments/lib/io.netty.netty-codec-dns-4.1.49.Final.jar:/deployments/lib/io.netty.netty-resolver-dns-4.1.49.Final.jar:/deployments/lib/com.fasterxml.jackson.core.jackson-core-2.12.1.jar:/deployments/lib/io.vertx.vertx-core-3.9.5.jar:/deployments/lib/io.quarkus.quarkus-vertx-core-1.12.0.Final.jar:/deployments/lib/io.vertx.vertx-web-common-3.9.5.jar:/deployments/lib/io.vertx.vertx-auth-common-3.9.5.jar:/deployments/lib/io.vertx.vertx-bridge-common-3.9.5.jar:/deployments/lib/io.vertx.vertx-web-3.9.5.jar:/deployments/lib/io.quarkus.quarkus-vertx-http-1.12.0.Final.jar:/deployments/lib/org.eclipse.microprofile.context-propagation.microprofile-context-propagation-api-1.0.1.jar:/deployments/lib/io.quarkus.quarkus-arc-1.12.0.Final.jar:/deployments/lib/org.jboss.spec.javax.ws.rs.jboss-jaxrs-api_2.1_spec-2.0.1.Final.jar:/deployments/lib/org.jboss.spec.javax.xml.bind.jboss-jaxb-api_2.3_spec-2.0.0.Final.jar:/deployments/lib/org.jboss.resteasy.resteasy-core-spi-4.5.9.Final.jar:/deployments/lib/com.ibm.async.asyncutil-0.1.0.jar:/deployments/lib/org.eclipse.microprofile.config.microprofile-config-api-1.4.jar:/deployments/lib/org.jboss.resteasy.resteasy-core-4.5.9.Final.jar:/deployments/lib/com.sun.activation.jakarta.activation-1.2.1.jar:/deployments/lib/io.quarkus.quarkus-resteasy-common-1.12.0.Final.jar:/deployments/lib/jakarta.validation.jakarta.validation-api-2.0.2.jar:/deployments/lib/io.quarkus.quarkus-resteasy-server-common-1.12.0.Final.jar:/deployments/lib/io.quarkus.quarkus-resteasy-1.12.0.Final.jar:/deployments/lib/io.quarkus.quarkus-kubernetes-client-internal-1.12.0.Final.jar:/deployments/lib/io.quarkus.quarkus-openshift-1.12.0.Final.jar
            - '-Dquarkus.http.host=0.0.0.0'
            - '-Djava.util.logging.manager=org.jboss.logmanager.LogManager' "

  
echo "apiVersion: apps/v1
kind: Deployment
metadata:
  name: rest-client-greeting
  namespace: $SM_MR_NS_2
  labels:
    app: rest-client-greeting
    app.kubernetes.io/name: rest-client-greeting
    app.kubernetes.io/version: 1.0.0-SNAPSHOT
    version: v1  
spec:
  selector:
    matchLabels:
      app: rest-client-greeting
      version: v1 
  replicas: 1
  template:
    metadata:
      labels:
        app: rest-client-greeting
        version: v1
      annotations:
        sidecar.istio.io/inject: 'true'        
    spec:
      containers:
        - name: rest-client-greeting
          command:
            - java         
          image: >-
            quay.io/skoussou/rest-client-greeting:1.0.0
          ports:
            - name: http
              containerPort: 8080
              protocol: TCP
          imagePullPolicy: Always              
          env:
            - name: KUBERNETES_NAMESPACE
              valueFrom:
                fieldRef:
                  apiVersion: v1
                  fieldPath: metadata.namespace
            - name: JAVA_LIB_DIR
              value: /deployments/lib
            - name: JAVA_APP_JAR
              value: /deployments/rest-client-greeting-1.0.0-SNAPSHOT-runner.jar
            - name: GREETINGS_SVC_LOCATION
              value: http://$REMOTE_SERVICE_ROUTE_NAME                       
          args:
            - '-jar'
            - /deployments/quarkus-run.jar
            - '-cp'
            - >-
              /deployments/lib/jakarta.annotation.jakarta.annotation-api-1.3.5.jar:/deployments/lib/jakarta.el.jakarta.el-api-3.0.3.jar:/deployments/lib/jakarta.interceptor.jakarta.interceptor-api-1.2.5.jar:/deployments/lib/jakarta.enterprise.jakarta.enterprise.cdi-api-2.0.2.jar:/deployments/lib/jakarta.inject.jakarta.inject-api-1.0.jar:/deployments/lib/io.quarkus.quarkus-development-mode-spi-1.12.0.Final.jar:/deployments/lib/io.smallrye.common.smallrye-common-annotation-1.5.0.jar:/deployments/lib/io.smallrye.config.smallrye-config-common-1.10.2.jar:/deployments/lib/io.smallrye.common.smallrye-common-function-1.5.0.jar:/deployments/lib/io.smallrye.common.smallrye-common-expression-1.5.0.jar:/deployments/lib/io.smallrye.common.smallrye-common-constraint-1.5.0.jar:/deployments/lib/io.smallrye.common.smallrye-common-classloader-1.5.0.jar:/deployments/lib/io.smallrye.config.smallrye-config-1.10.2.jar:/deployments/lib/org.jboss.logging.jboss-logging-3.4.1.Final.jar:/deployments/lib/org.jboss.logmanager.jboss-logmanager-embedded-1.0.6.jar:/deployments/lib/org.jboss.logging.jboss-logging-annotations-2.2.0.Final.jar:/deployments/lib/org.jboss.threads.jboss-threads-3.2.0.Final.jar:/deployments/lib/org.slf4j.slf4j-api-1.7.30.jar:/deployments/lib/org.jboss.slf4j.slf4j-jboss-logmanager-1.1.0.Final.jar:/deployments/lib/org.graalvm.sdk.graal-sdk-21.0.0.jar:/deployments/lib/org.wildfly.common.wildfly-common-1.5.4.Final-format-001.jar:/deployments/lib/io.smallrye.common.smallrye-common-io-1.5.0.jar:/deployments/lib/io.quarkus.quarkus-bootstrap-runner-1.12.0.Final.jar:/deployments/lib/io.quarkus.quarkus-core-1.12.0.Final.jar:/deployments/lib/io.quarkus.quarkus-security-runtime-spi-1.12.0.Final.jar:/deployments/lib/jakarta.transaction.jakarta.transaction-api-1.3.3.jar:/deployments/lib/io.quarkus.arc.arc-1.12.0.Final.jar:/deployments/lib/io.quarkus.quarkus-vertx-http-dev-console-runtime-spi-1.12.0.Final.jar:/deployments/lib/org.reactivestreams.reactive-streams-1.0.3.jar:/deployments/lib/io.smallrye.reactive.mutiny-0.13.0.jar:/deployments/lib/io.quarkus.security.quarkus-security-1.1.3.Final.jar:/deployments/lib/io.netty.netty-codec-4.1.49.Final.jar:/deployments/lib/io.netty.netty-handler-4.1.49.Final.jar:/deployments/lib/io.quarkus.quarkus-netty-1.12.0.Final.jar:/deployments/lib/io.netty.netty-common-4.1.49.Final.jar:/deployments/lib/io.netty.netty-buffer-4.1.49.Final.jar:/deployments/lib/io.netty.netty-transport-4.1.49.Final.jar:/deployments/lib/io.netty.netty-codec-socks-4.1.49.Final.jar:/deployments/lib/io.netty.netty-handler-proxy-4.1.49.Final.jar:/deployments/lib/io.netty.netty-codec-http-4.1.49.Final.jar:/deployments/lib/io.netty.netty-codec-http2-4.1.49.Final.jar:/deployments/lib/io.netty.netty-resolver-4.1.49.Final.jar:/deployments/lib/io.netty.netty-codec-dns-4.1.49.Final.jar:/deployments/lib/io.netty.netty-resolver-dns-4.1.49.Final.jar:/deployments/lib/com.fasterxml.jackson.core.jackson-core-2.12.1.jar:/deployments/lib/io.vertx.vertx-core-3.9.5.jar:/deployments/lib/io.quarkus.quarkus-vertx-core-1.12.0.Final.jar:/deployments/lib/io.vertx.vertx-web-common-3.9.5.jar:/deployments/lib/io.vertx.vertx-auth-common-3.9.5.jar:/deployments/lib/io.vertx.vertx-bridge-common-3.9.5.jar:/deployments/lib/io.vertx.vertx-web-3.9.5.jar:/deployments/lib/io.quarkus.quarkus-vertx-http-1.12.0.Final.jar:/deployments/lib/org.eclipse.microprofile.context-propagation.microprofile-context-propagation-api-1.0.1.jar:/deployments/lib/io.quarkus.quarkus-arc-1.12.0.Final.jar:/deployments/lib/org.jboss.spec.javax.ws.rs.jboss-jaxrs-api_2.1_spec-2.0.1.Final.jar:/deployments/lib/org.jboss.spec.javax.xml.bind.jboss-jaxb-api_2.3_spec-2.0.0.Final.jar:/deployments/lib/org.jboss.resteasy.resteasy-core-spi-4.5.9.Final.jar:/deployments/lib/com.ibm.async.asyncutil-0.1.0.jar:/deployments/lib/org.eclipse.microprofile.config.microprofile-config-api-1.4.jar:/deployments/lib/org.jboss.resteasy.resteasy-core-4.5.9.Final.jar:/deployments/lib/com.sun.activation.jakarta.activation-1.2.1.jar:/deployments/lib/io.quarkus.quarkus-resteasy-common-1.12.0.Final.jar:/deployments/lib/jakarta.validation.jakarta.validation-api-2.0.2.jar:/deployments/lib/io.quarkus.quarkus-resteasy-server-common-1.12.0.Final.jar:/deployments/lib/io.quarkus.quarkus-resteasy-1.12.0.Final.jar:/deployments/lib/io.quarkus.quarkus-kubernetes-client-internal-1.12.0.Final.jar:/deployments/lib/io.quarkus.quarkus-openshift-1.12.0.Final.jar
            - '-Dquarkus.http.host=0.0.0.0'
            - '-Djava.util.logging.manager=org.jboss.logmanager.LogManager' " |oc apply -f -
   
   

echo
echo "################# Service - rest-client-greeting [$SM_MR_NS] #################"   
echo 
echo "apiVersion: v1
kind: Service
metadata:
  name: rest-client-greeting
  namespace: $SM_MR_NS
spec:
  selector:
    app: rest-client-greeting
  ports:
    - protocol: TCP
      name: http-web
      port: 8080
      targetPort: 8080" | oc apply -f -   
   
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
  ports:
    - name: http
      number: 443
      protocol: HTTP2
  location: MESH_EXTERNAL
  resolution: DNS
  exportTo:
  - '*'" 
  
echo "kind: ServiceEntry
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: rest-greeting-remote-mesh-ext
  namespace: $SM_MR_NS
spec:
  hosts:
    - ${REMOTE_SERVICE_ROUTE_NAME}
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
  - '.'"   
echo "kind: DestinationRule
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: egress-originate-tls-to-rest-greeting-remote
  namespace: $SM_MR_NS  
spec:
  host: istio-egressgateway.${SM_CP_NS}.svc.cluster.local
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
echo "################# Testing against Host [$(oc get route istio-ingressgateway -o jsonpath='{.spec.host}' -n $SM_CP_NS)]  #################"        
echo 
watch curl -X GET http://$(oc get route istio-ingressgateway -o jsonpath='{.spec.host}' -n $SM_CP_NS)/say/goodday-to/Stelios



# WORKING CONFIGS FROM APP NAMESPACE          
#working-app-names-ace-egress-mtls-setup.yaml    

# WORKING CONFIGS FROM BOTH APP and ISTIO-SYSTEM NAMESPACE                
          

