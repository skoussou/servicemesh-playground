#!/bin/bash

SM_CP_NS=$1
SM_TENANT_NAME=$2
SM_MR_NS=$3
REMOTE_SERVICE_ROUTE=$4 #eg. hello.remote.com
CLUSTER_NAME=$5

SM_CP_NS_2=$6
SM_TENANT_NAME_2=$7
SM_MR_NS_2=$8

echo '---------------------------------------------------------------------------'
echo 'ServiceMesh Control Plane Namespace             : '$SM_CP_NS
echo 'ServiceMesh Control Plane Tenant Name           : '$SM_TENANT_NAME
echo 'ServiceMesh Member Namespace                    : '$SM_MR_NS
echo 'Remote Service Route                            : '$REMOTE_SERVICE_ROUTE
echo 'Remote Cluster Name                             : '$CLUSTER_NAME
echo
echo 'ServiceMesh Control Plane Namespace (Client)    : '$SM_CP_NS_2
echo 'ServiceMesh Control Plane Tenant Name (Client)  : '$SM_TENANT_NAME_2
echo 'ServiceMesh Member Namespace (Client)           : '$SM_MR_NS_2
echo '---------------------------------------------------------------------------'

cd ../coded-services/quarkus-rest-greeting-remote
oc new-project $SM_MR_NS
oc project  $SM_MR_NS

 
cd ../../Scenario-MTLS-3-SM-Service-To-External-MTLS-Handling
echo
echo "################# SMR [$SM_MR_NS] added in SMCP [ns:$SM_CP_NS name: $SM_TENANT_NAME] #################"   
echo "sh  ../scripts/create-membership.sh $SM_CP_NS $SM_TENANT_NAME $SM_MR_NS"
sh ../scripts/create-membership.sh $SM_CP_NS $SM_TENANT_NAME $SM_MR_NS


sleep 15

echo 
echo '################## Creation of [est-greeting-remote] Application Deployment ##################'
echo "apiVersion: apps/v1
kind: Deployment
metadata:
  name: rest-greeting-remote
  namespace: $SM_MR_NS
  labels:
    app: rest-greeting-remote
    app.kubernetes.io/name: rest-greeting-remote
    app.kubernetes.io/version: 1.0.0-SNAPSHOT
    version: v1  
spec:
  selector:
    matchLabels:
      app: rest-greeting-remote
      version: v1 
  replicas: 1
  template:
    metadata:
      labels:
        app: rest-greeting-remote
        version: v1
      annotations:
        sidecar.istio.io/inject: 'true'        
    spec:
      containers:
        - name: rest-greeting-remote
          command:
            - java         
          image: >-
            quay.io/skoussou/rest-greeting-remote:1.0.0
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
              value: /deployments/rest-greeting-remote-1.0.0-SNAPSHOT-runner.jar
            - name: GREETINGS_SVC_LOCATION
              value: $REMOTE_SERVICE_ROUTE
            - name: GREETING_LOCATION
              value: $CLUSTER_NAME                       
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
  name: rest-greeting-remote
  namespace: $SM_MR_NS
  labels:
    app: rest-greeting-remote
    app.kubernetes.io/name: rest-greeting-remote
    app.kubernetes.io/version: 1.0.0-SNAPSHOT
    version: v1  
spec:
  selector:
    matchLabels:
      app: rest-greeting-remote
      version: v1 
  replicas: 1
  template:
    metadata:
      labels:
        app: rest-greeting-remote
        version: v1
      annotations:
        sidecar.istio.io/inject: 'true'        
    spec:
      containers:
        - name: rest-greeting-remote
          command:
            - java         
          image: >-
            quay.io/skoussou/rest-greeting-remote:1.0.0
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
              value: /deployments/rest-greeting-remote-1.0.0-SNAPSHOT-runner.jar
            - name: GREETINGS_SVC_LOCATION
              value: $REMOTE_SERVICE_ROUTE
            - name: GREETING_LOCATION
              value: $CLUSTER_NAME                       
          args:
            - '-jar'
            - /deployments/quarkus-run.jar
            - '-cp'
            - >-
              /deployments/lib/jakarta.annotation.jakarta.annotation-api-1.3.5.jar:/deployments/lib/jakarta.el.jakarta.el-api-3.0.3.jar:/deployments/lib/jakarta.interceptor.jakarta.interceptor-api-1.2.5.jar:/deployments/lib/jakarta.enterprise.jakarta.enterprise.cdi-api-2.0.2.jar:/deployments/lib/jakarta.inject.jakarta.inject-api-1.0.jar:/deployments/lib/io.quarkus.quarkus-development-mode-spi-1.12.0.Final.jar:/deployments/lib/io.smallrye.common.smallrye-common-annotation-1.5.0.jar:/deployments/lib/io.smallrye.config.smallrye-config-common-1.10.2.jar:/deployments/lib/io.smallrye.common.smallrye-common-function-1.5.0.jar:/deployments/lib/io.smallrye.common.smallrye-common-expression-1.5.0.jar:/deployments/lib/io.smallrye.common.smallrye-common-constraint-1.5.0.jar:/deployments/lib/io.smallrye.common.smallrye-common-classloader-1.5.0.jar:/deployments/lib/io.smallrye.config.smallrye-config-1.10.2.jar:/deployments/lib/org.jboss.logging.jboss-logging-3.4.1.Final.jar:/deployments/lib/org.jboss.logmanager.jboss-logmanager-embedded-1.0.6.jar:/deployments/lib/org.jboss.logging.jboss-logging-annotations-2.2.0.Final.jar:/deployments/lib/org.jboss.threads.jboss-threads-3.2.0.Final.jar:/deployments/lib/org.slf4j.slf4j-api-1.7.30.jar:/deployments/lib/org.jboss.slf4j.slf4j-jboss-logmanager-1.1.0.Final.jar:/deployments/lib/org.graalvm.sdk.graal-sdk-21.0.0.jar:/deployments/lib/org.wildfly.common.wildfly-common-1.5.4.Final-format-001.jar:/deployments/lib/io.smallrye.common.smallrye-common-io-1.5.0.jar:/deployments/lib/io.quarkus.quarkus-bootstrap-runner-1.12.0.Final.jar:/deployments/lib/io.quarkus.quarkus-core-1.12.0.Final.jar:/deployments/lib/io.quarkus.quarkus-security-runtime-spi-1.12.0.Final.jar:/deployments/lib/jakarta.transaction.jakarta.transaction-api-1.3.3.jar:/deployments/lib/io.quarkus.arc.arc-1.12.0.Final.jar:/deployments/lib/io.quarkus.quarkus-vertx-http-dev-console-runtime-spi-1.12.0.Final.jar:/deployments/lib/org.reactivestreams.reactive-streams-1.0.3.jar:/deployments/lib/io.smallrye.reactive.mutiny-0.13.0.jar:/deployments/lib/io.quarkus.security.quarkus-security-1.1.3.Final.jar:/deployments/lib/io.netty.netty-codec-4.1.49.Final.jar:/deployments/lib/io.netty.netty-handler-4.1.49.Final.jar:/deployments/lib/io.quarkus.quarkus-netty-1.12.0.Final.jar:/deployments/lib/io.netty.netty-common-4.1.49.Final.jar:/deployments/lib/io.netty.netty-buffer-4.1.49.Final.jar:/deployments/lib/io.netty.netty-transport-4.1.49.Final.jar:/deployments/lib/io.netty.netty-codec-socks-4.1.49.Final.jar:/deployments/lib/io.netty.netty-handler-proxy-4.1.49.Final.jar:/deployments/lib/io.netty.netty-codec-http-4.1.49.Final.jar:/deployments/lib/io.netty.netty-codec-http2-4.1.49.Final.jar:/deployments/lib/io.netty.netty-resolver-4.1.49.Final.jar:/deployments/lib/io.netty.netty-codec-dns-4.1.49.Final.jar:/deployments/lib/io.netty.netty-resolver-dns-4.1.49.Final.jar:/deployments/lib/com.fasterxml.jackson.core.jackson-core-2.12.1.jar:/deployments/lib/io.vertx.vertx-core-3.9.5.jar:/deployments/lib/io.quarkus.quarkus-vertx-core-1.12.0.Final.jar:/deployments/lib/io.vertx.vertx-web-common-3.9.5.jar:/deployments/lib/io.vertx.vertx-auth-common-3.9.5.jar:/deployments/lib/io.vertx.vertx-bridge-common-3.9.5.jar:/deployments/lib/io.vertx.vertx-web-3.9.5.jar:/deployments/lib/io.quarkus.quarkus-vertx-http-1.12.0.Final.jar:/deployments/lib/org.eclipse.microprofile.context-propagation.microprofile-context-propagation-api-1.0.1.jar:/deployments/lib/io.quarkus.quarkus-arc-1.12.0.Final.jar:/deployments/lib/org.jboss.spec.javax.ws.rs.jboss-jaxrs-api_2.1_spec-2.0.1.Final.jar:/deployments/lib/org.jboss.spec.javax.xml.bind.jboss-jaxb-api_2.3_spec-2.0.0.Final.jar:/deployments/lib/org.jboss.resteasy.resteasy-core-spi-4.5.9.Final.jar:/deployments/lib/com.ibm.async.asyncutil-0.1.0.jar:/deployments/lib/org.eclipse.microprofile.config.microprofile-config-api-1.4.jar:/deployments/lib/org.jboss.resteasy.resteasy-core-4.5.9.Final.jar:/deployments/lib/com.sun.activation.jakarta.activation-1.2.1.jar:/deployments/lib/io.quarkus.quarkus-resteasy-common-1.12.0.Final.jar:/deployments/lib/jakarta.validation.jakarta.validation-api-2.0.2.jar:/deployments/lib/io.quarkus.quarkus-resteasy-server-common-1.12.0.Final.jar:/deployments/lib/io.quarkus.quarkus-resteasy-1.12.0.Final.jar:/deployments/lib/io.quarkus.quarkus-kubernetes-client-internal-1.12.0.Final.jar:/deployments/lib/io.quarkus.quarkus-openshift-1.12.0.Final.jar
            - '-Dquarkus.http.host=0.0.0.0'
            - '-Djava.util.logging.manager=org.jboss.logmanager.LogManager' "|oc apply -f -  

sleep 5

echo
echo "################# Service - rest-greeting-remote [$SM_MR_NS] #################"   
echo 
echo "apiVersion: v1
kind: Service
metadata:
  name: rest-greeting-remote
  namespace: $SM_MR_NS
spec:
  selector:
    app: rest-greeting-remote
  ports:
    - protocol: TCP
      name: http-web
      port: 8080
      targetPort: 8080" | oc apply -f -  


echo
echo
echo "################# Route - hello-remote [$SM_CP_NS] #################"   
echo
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
  wildcardPolicy: None"
  
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
    targetPort: http
  wildcardPolicy: None" | oc apply -n $SM_CP_NS -f -   
  
echo "################# Gateway - rest-greeting-remote-gateway [$SM_MR_NS] #################"     
echo
echo "apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: rest-greeting-remote-gateway
spec:
  selector:
    istio: ingressgateway # use istio default gateway service
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - $REMOTE_SERVICE_ROUTE"
    
echo "apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: rest-greeting-remote-gateway
spec:
  selector:
    istio: ingressgateway # use istio default gateway service
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
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
          
          
#echo "ROUTE="
#echo $(oc get route hello-remote -o jsonpath='{.spec.host}' -n $SM_CP_NS)
#echo
#echo
#sleep 5
#watch curl -X GET http://$(oc get route hello-remote -o jsonpath='{.spec.host}' -n $SM_CP_NS)/hello
                    



echo '---------------------------------------------------------------------------'
echo 'ServiceMesh Control Plane Namespace        : '$SM_CP_NS_2
echo 'ServiceMesh Control Plane Tenant Name      : '$SM_TENANT_NAME_2
echo 'ServiceMesh Member Namespace               : '$SM_MR_NS_2
echo 'Remote Service Route                       : '$REMOTE_SERVICE_ROUTE
echo '---------------------------------------------------------------------------'

cd ../coded-services/quarkus-rest-client-greeting
oc new-project $SM_MR_NS_2
oc project  $SM_MR_NS_2          
          
cd ../../Scenario-MTLS-3-SM-Service-To-External-MTLS-Handling
echo
echo "################# SMR [$SM_MR_NS_2] added in SMCP [ns:$SM_CP_NS_" name: $SM_TENANT_NAME_2] #################"   
echo "sh  ../scripts/create-membership.sh $SM_CP_NS_2 $SM_TENANT_NAME_2 $SM_MR_NS_2"
sh ../scripts/create-membership.sh $SM_CP_NS_2 $SM_TENANT_NAME_2 $SM_MR_NS_2


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
              value: http://$REMOTE_SERVICE_ROUTE                    
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
              value: http://$REMOTE_SERVICE_ROUTE                       
          args:
            - '-jar'
            - /deployments/quarkus-run.jar
            - '-cp'
            - >-
              /deployments/lib/jakarta.annotation.jakarta.annotation-api-1.3.5.jar:/deployments/lib/jakarta.el.jakarta.el-api-3.0.3.jar:/deployments/lib/jakarta.interceptor.jakarta.interceptor-api-1.2.5.jar:/deployments/lib/jakarta.enterprise.jakarta.enterprise.cdi-api-2.0.2.jar:/deployments/lib/jakarta.inject.jakarta.inject-api-1.0.jar:/deployments/lib/io.quarkus.quarkus-development-mode-spi-1.12.0.Final.jar:/deployments/lib/io.smallrye.common.smallrye-common-annotation-1.5.0.jar:/deployments/lib/io.smallrye.config.smallrye-config-common-1.10.2.jar:/deployments/lib/io.smallrye.common.smallrye-common-function-1.5.0.jar:/deployments/lib/io.smallrye.common.smallrye-common-expression-1.5.0.jar:/deployments/lib/io.smallrye.common.smallrye-common-constraint-1.5.0.jar:/deployments/lib/io.smallrye.common.smallrye-common-classloader-1.5.0.jar:/deployments/lib/io.smallrye.config.smallrye-config-1.10.2.jar:/deployments/lib/org.jboss.logging.jboss-logging-3.4.1.Final.jar:/deployments/lib/org.jboss.logmanager.jboss-logmanager-embedded-1.0.6.jar:/deployments/lib/org.jboss.logging.jboss-logging-annotations-2.2.0.Final.jar:/deployments/lib/org.jboss.threads.jboss-threads-3.2.0.Final.jar:/deployments/lib/org.slf4j.slf4j-api-1.7.30.jar:/deployments/lib/org.jboss.slf4j.slf4j-jboss-logmanager-1.1.0.Final.jar:/deployments/lib/org.graalvm.sdk.graal-sdk-21.0.0.jar:/deployments/lib/org.wildfly.common.wildfly-common-1.5.4.Final-format-001.jar:/deployments/lib/io.smallrye.common.smallrye-common-io-1.5.0.jar:/deployments/lib/io.quarkus.quarkus-bootstrap-runner-1.12.0.Final.jar:/deployments/lib/io.quarkus.quarkus-core-1.12.0.Final.jar:/deployments/lib/io.quarkus.quarkus-security-runtime-spi-1.12.0.Final.jar:/deployments/lib/jakarta.transaction.jakarta.transaction-api-1.3.3.jar:/deployments/lib/io.quarkus.arc.arc-1.12.0.Final.jar:/deployments/lib/io.quarkus.quarkus-vertx-http-dev-console-runtime-spi-1.12.0.Final.jar:/deployments/lib/org.reactivestreams.reactive-streams-1.0.3.jar:/deployments/lib/io.smallrye.reactive.mutiny-0.13.0.jar:/deployments/lib/io.quarkus.security.quarkus-security-1.1.3.Final.jar:/deployments/lib/io.netty.netty-codec-4.1.49.Final.jar:/deployments/lib/io.netty.netty-handler-4.1.49.Final.jar:/deployments/lib/io.quarkus.quarkus-netty-1.12.0.Final.jar:/deployments/lib/io.netty.netty-common-4.1.49.Final.jar:/deployments/lib/io.netty.netty-buffer-4.1.49.Final.jar:/deployments/lib/io.netty.netty-transport-4.1.49.Final.jar:/deployments/lib/io.netty.netty-codec-socks-4.1.49.Final.jar:/deployments/lib/io.netty.netty-handler-proxy-4.1.49.Final.jar:/deployments/lib/io.netty.netty-codec-http-4.1.49.Final.jar:/deployments/lib/io.netty.netty-codec-http2-4.1.49.Final.jar:/deployments/lib/io.netty.netty-resolver-4.1.49.Final.jar:/deployments/lib/io.netty.netty-codec-dns-4.1.49.Final.jar:/deployments/lib/io.netty.netty-resolver-dns-4.1.49.Final.jar:/deployments/lib/com.fasterxml.jackson.core.jackson-core-2.12.1.jar:/deployments/lib/io.vertx.vertx-core-3.9.5.jar:/deployments/lib/io.quarkus.quarkus-vertx-core-1.12.0.Final.jar:/deployments/lib/io.vertx.vertx-web-common-3.9.5.jar:/deployments/lib/io.vertx.vertx-auth-common-3.9.5.jar:/deployments/lib/io.vertx.vertx-bridge-common-3.9.5.jar:/deployments/lib/io.vertx.vertx-web-3.9.5.jar:/deployments/lib/io.quarkus.quarkus-vertx-http-1.12.0.Final.jar:/deployments/lib/org.eclipse.microprofile.context-propagation.microprofile-context-propagation-api-1.0.1.jar:/deployments/lib/io.quarkus.quarkus-arc-1.12.0.Final.jar:/deployments/lib/org.jboss.spec.javax.ws.rs.jboss-jaxrs-api_2.1_spec-2.0.1.Final.jar:/deployments/lib/org.jboss.spec.javax.xml.bind.jboss-jaxb-api_2.3_spec-2.0.0.Final.jar:/deployments/lib/org.jboss.resteasy.resteasy-core-spi-4.5.9.Final.jar:/deployments/lib/com.ibm.async.asyncutil-0.1.0.jar:/deployments/lib/org.eclipse.microprofile.config.microprofile-config-api-1.4.jar:/deployments/lib/org.jboss.resteasy.resteasy-core-4.5.9.Final.jar:/deployments/lib/com.sun.activation.jakarta.activation-1.2.1.jar:/deployments/lib/io.quarkus.quarkus-resteasy-common-1.12.0.Final.jar:/deployments/lib/jakarta.validation.jakarta.validation-api-2.0.2.jar:/deployments/lib/io.quarkus.quarkus-resteasy-server-common-1.12.0.Final.jar:/deployments/lib/io.quarkus.quarkus-resteasy-1.12.0.Final.jar:/deployments/lib/io.quarkus.quarkus-kubernetes-client-internal-1.12.0.Final.jar:/deployments/lib/io.quarkus.quarkus-openshift-1.12.0.Final.jar
            - '-Dquarkus.http.host=0.0.0.0'
            - '-Djava.util.logging.manager=org.jboss.logmanager.LogManager' "|oc apply -f -            
          
          
echo
echo "################# Service - rest-client-greeting [$SM_MR_NS_2] #################"   
echo 
echo "apiVersion: v1
kind: Service
metadata:
  name: rest-client-greeting
  namespace: $SM_MR_NS_2
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
echo "################# Gateway - rest-client-gateway [$SM_CP_NS_2] #################"
echo "apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: rest-client-gateway
  namespace: $SM_CP_NS_2
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
echo "################# VirtualService - rest-client-greeting [$SM_MR_NS_2] #################"
echo "apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: rest-client-greeting
  namespace: $SM_MR_NS_2  
spec:
  hosts:
  - '*'
  gateways:
  - $SM_CP_NS_2/rest-client-gateway
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
  - $SM_CP_NS_2" | oc apply -f -     

echo 
echo "#############################################################################"
echo "#		OUTGOING TRAFFIC SM CONFIGS                                        #"
echo "#############################################################################"
echo           
echo "################# ServiceEntry - rest-greeting-remote-mesh-ext [$SM_MR_NS_2] #################"    
echo "kind: ServiceEntry
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: rest-greeting-remote-mesh-ext
  namespace: $SM_MR_NS_2
spec:
  hosts:
    - ${REMOTE_SERVICE_ROUTE}
  addresses: ~
  ports:
    - name: http
      number: 80
      protocol: HTTP2
  location: MESH_EXTERNAL
  resolution: DNS
  exportTo:
  - '*'" | oc apply -f -    

          
echo
echo "########## DIRECT Requests to Egress Gateway ################################"
echo    
# 1. Create an egress Gateway for my-nginx.mesh-external.svc.cluster.local, port 443,  
echo "################# Gateway - rest-greeting-remote-mtls-gateway [$SM_CP_NS_2] #################"      
echo "apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: istio-egressgateway
  namespace: $SM_CP_NS_2 
spec:
  selector:
    istio: egressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - ${REMOTE_SERVICE_ROUTE}" | oc apply -f -           
      
      
echo "################# DestinationRule - egress-originate-to-rest-greeting-remote-destination-rule [$SM_MR_NS_2] #################"    
echo "kind: DestinationRule
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: egress-originate-to-rest-greeting-remote
  namespace: $SM_MR_NS_2  
spec:
  host: istio-egressgateway.${SM_CP_NS_2}.svc.cluster.local
  trafficPolicy:
  subsets:
  - name: greeting-remote
    trafficPolicy:
      loadBalancer:
        simple: ROUND_ROBIN
  exportTo:
  - '.'" | oc apply -f -   
  
echo   
echo "################# VirtualService - route-mesh-gw-to-egress-gw [$SM_MR_NS_2] #################"        
echo "kind: VirtualService
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: route-mesh-gw-to-egress-gw
  namespace: $SM_MR_NS_2
spec:
  hosts:
    - ${REMOTE_SERVICE_ROUTE}
  gateways:
    - mesh
  http:
    - match:
        - gateways:
            - mesh
          port: 80
      route:
        - destination:
            host: istio-egressgateway.${SM_CP_NS_2}.svc.cluster.local
            subset: greeting-remote
          weight: 100
  exportTo:
    - ." | oc apply -f -     
        
      
echo   
echo "################# VirtualService - route-egress-gw-to-ext [$SM_CP_NS_2  ] #################"        
echo "kind: VirtualService
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: route-egress-gw-to-ext
  namespace: $SM_CP_NS_2    
spec:
  hosts:
    - ${REMOTE_SERVICE_ROUTE}
  gateways:
    - istio-egressgateway
  http:
    - match:
        - gateways:
            - istio-egressgateway
      route:
        - destination:
            host: ${REMOTE_SERVICE_ROUTE}
            port:
              number: 80
          weight: 100
  exportTo:
    - ." | oc apply -f -        
      

sleep 15
echo   
echo "################# Testing against Host [$(oc get route istio-ingressgateway -o jsonpath='{.spec.host}' -n $SM_CP_NS_2)]  #################"        
echo 
watch curl -X GET http://$(oc get route istio-ingressgateway -o jsonpath='{.spec.host}' -n $SM_CP_NS_2)/say/goodday-to/Stelios      
      
      
      
      
      
      
      
      
      
      
      
      
                
          
          

