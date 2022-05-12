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

oc new-project $SM_MR_NS_1
oc project  $SM_MR_NS_1

echo
echo "################# SMR [$SM_MR_NS_1] added in SMCP [ns:$SM_CP_NS name: $SM_TENANT_NAME] #################"   
echo "sh  ../scripts/create-membership.sh $SM_CP_NS $SM_TENANT_NAME $SM_MR_NS_1"
sh ../scripts/create-membership.sh $SM_CP_NS $SM_TENANT_NAME $SM_MR_NS_1

sleep 15  

echo 
echo '################## Creation of Application [rest-client-greeting] Deployment ##################'
echo "apiVersion: apps/v1
kind: Deployment
metadata:
  name: rest-client-greeting
  namespace: $SM_MR_NS_1
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
  namespace: $SM_MR_NS_1
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
            - '-Djava.util.logging.manager=org.jboss.logmanager.LogManager' "|oc apply -f -

echo
echo "################# Service - rest-client-greeting [$SM_MR_NS_1] #################"   
echo 
echo "apiVersion: v1
kind: Service
metadata:
  name: rest-client-greeting
  namespace: $SM_MR_NS_1
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

oc new-project $SM_MR_NS_2
oc project  $SM_MR_NS_2

   
echo 
echo '################## Creation of [est-greeting-remote] Application Deployment ##################'
echo "apiVersion: apps/v1
kind: Deployment
metadata:
  name: rest-greeting-remote
  namespace: $SM_MR_NS_2
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
  namespace: $SM_MR_NS_2
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
          args:
            - '-jar'
            - /deployments/quarkus-run.jar
            - '-cp'
            - >-
              /deployments/lib/jakarta.annotation.jakarta.annotation-api-1.3.5.jar:/deployments/lib/jakarta.el.jakarta.el-api-3.0.3.jar:/deployments/lib/jakarta.interceptor.jakarta.interceptor-api-1.2.5.jar:/deployments/lib/jakarta.enterprise.jakarta.enterprise.cdi-api-2.0.2.jar:/deployments/lib/jakarta.inject.jakarta.inject-api-1.0.jar:/deployments/lib/io.quarkus.quarkus-development-mode-spi-1.12.0.Final.jar:/deployments/lib/io.smallrye.common.smallrye-common-annotation-1.5.0.jar:/deployments/lib/io.smallrye.config.smallrye-config-common-1.10.2.jar:/deployments/lib/io.smallrye.common.smallrye-common-function-1.5.0.jar:/deployments/lib/io.smallrye.common.smallrye-common-expression-1.5.0.jar:/deployments/lib/io.smallrye.common.smallrye-common-constraint-1.5.0.jar:/deployments/lib/io.smallrye.common.smallrye-common-classloader-1.5.0.jar:/deployments/lib/io.smallrye.config.smallrye-config-1.10.2.jar:/deployments/lib/org.jboss.logging.jboss-logging-3.4.1.Final.jar:/deployments/lib/org.jboss.logmanager.jboss-logmanager-embedded-1.0.6.jar:/deployments/lib/org.jboss.logging.jboss-logging-annotations-2.2.0.Final.jar:/deployments/lib/org.jboss.threads.jboss-threads-3.2.0.Final.jar:/deployments/lib/org.slf4j.slf4j-api-1.7.30.jar:/deployments/lib/org.jboss.slf4j.slf4j-jboss-logmanager-1.1.0.Final.jar:/deployments/lib/org.graalvm.sdk.graal-sdk-21.0.0.jar:/deployments/lib/org.wildfly.common.wildfly-common-1.5.4.Final-format-001.jar:/deployments/lib/io.smallrye.common.smallrye-common-io-1.5.0.jar:/deployments/lib/io.quarkus.quarkus-bootstrap-runner-1.12.0.Final.jar:/deployments/lib/io.quarkus.quarkus-core-1.12.0.Final.jar:/deployments/lib/io.quarkus.quarkus-security-runtime-spi-1.12.0.Final.jar:/deployments/lib/jakarta.transaction.jakarta.transaction-api-1.3.3.jar:/deployments/lib/io.quarkus.arc.arc-1.12.0.Final.jar:/deployments/lib/io.quarkus.quarkus-vertx-http-dev-console-runtime-spi-1.12.0.Final.jar:/deployments/lib/org.reactivestreams.reactive-streams-1.0.3.jar:/deployments/lib/io.smallrye.reactive.mutiny-0.13.0.jar:/deployments/lib/io.quarkus.security.quarkus-security-1.1.3.Final.jar:/deployments/lib/io.netty.netty-codec-4.1.49.Final.jar:/deployments/lib/io.netty.netty-handler-4.1.49.Final.jar:/deployments/lib/io.quarkus.quarkus-netty-1.12.0.Final.jar:/deployments/lib/io.netty.netty-common-4.1.49.Final.jar:/deployments/lib/io.netty.netty-buffer-4.1.49.Final.jar:/deployments/lib/io.netty.netty-transport-4.1.49.Final.jar:/deployments/lib/io.netty.netty-codec-socks-4.1.49.Final.jar:/deployments/lib/io.netty.netty-handler-proxy-4.1.49.Final.jar:/deployments/lib/io.netty.netty-codec-http-4.1.49.Final.jar:/deployments/lib/io.netty.netty-codec-http2-4.1.49.Final.jar:/deployments/lib/io.netty.netty-resolver-4.1.49.Final.jar:/deployments/lib/io.netty.netty-codec-dns-4.1.49.Final.jar:/deployments/lib/io.netty.netty-resolver-dns-4.1.49.Final.jar:/deployments/lib/com.fasterxml.jackson.core.jackson-core-2.12.1.jar:/deployments/lib/io.vertx.vertx-core-3.9.5.jar:/deployments/lib/io.quarkus.quarkus-vertx-core-1.12.0.Final.jar:/deployments/lib/io.vertx.vertx-web-common-3.9.5.jar:/deployments/lib/io.vertx.vertx-auth-common-3.9.5.jar:/deployments/lib/io.vertx.vertx-bridge-common-3.9.5.jar:/deployments/lib/io.vertx.vertx-web-3.9.5.jar:/deployments/lib/io.quarkus.quarkus-vertx-http-1.12.0.Final.jar:/deployments/lib/org.eclipse.microprofile.context-propagation.microprofile-context-propagation-api-1.0.1.jar:/deployments/lib/io.quarkus.quarkus-arc-1.12.0.Final.jar:/deployments/lib/org.jboss.spec.javax.ws.rs.jboss-jaxrs-api_2.1_spec-2.0.1.Final.jar:/deployments/lib/org.jboss.spec.javax.xml.bind.jboss-jaxb-api_2.3_spec-2.0.0.Final.jar:/deployments/lib/org.jboss.resteasy.resteasy-core-spi-4.5.9.Final.jar:/deployments/lib/com.ibm.async.asyncutil-0.1.0.jar:/deployments/lib/org.eclipse.microprofile.config.microprofile-config-api-1.4.jar:/deployments/lib/org.jboss.resteasy.resteasy-core-4.5.9.Final.jar:/deployments/lib/com.sun.activation.jakarta.activation-1.2.1.jar:/deployments/lib/io.quarkus.quarkus-resteasy-common-1.12.0.Final.jar:/deployments/lib/jakarta.validation.jakarta.validation-api-2.0.2.jar:/deployments/lib/io.quarkus.quarkus-resteasy-server-common-1.12.0.Final.jar:/deployments/lib/io.quarkus.quarkus-resteasy-1.12.0.Final.jar:/deployments/lib/io.quarkus.quarkus-kubernetes-client-internal-1.12.0.Final.jar:/deployments/lib/io.quarkus.quarkus-openshift-1.12.0.Final.jar
            - '-Dquarkus.http.host=0.0.0.0'
            - '-Djava.util.logging.manager=org.jboss.logmanager.LogManager' "|oc apply -f -        
   
sleep 10   
   
   
echo
echo "################# Service - rest-greeting-remote [$SM_MR_NS_2] #################"   
echo 
echo "apiVersion: v1
kind: Service
metadata:
  name: rest-greeting-remote
  namespace: $SM_MR_NS_2
spec:
  selector:
    app: rest-greeting-remote
  ports:
    - protocol: TCP
      name: http-web
      port: 8080
      targetPort: 8080" | oc apply -f -    
   
   
echo
echo "#############################################################################"
echo "#		Testing                                                           #"
echo "#############################################################################"
echo 
watch curl -X GET http://$(oc get route istio-ingressgateway -o jsonpath='{.spec.host}' -n $SM_CP_NS)/say/goodday-to/Stelios
