#!/bin/bash

SM_CP_NS=$1
SM_TENANT_NAME=$2
SM_MR_NS=$3
REMOTE_SERVICE_ROUTE=$4 #eg. hello.remote.com
CERTIFICATE_SECRET_NAME=$5
CLUSTER_NAME=$6

echo '---------------------------------------------------------------------------'
echo 'ServiceMesh Namespace                      : '$SM_CP_NS
echo 'ServiceMesh Control Plane Tenant Name      : '$SM_TENANT_NAME
echo 'ServiceMesh Member Namespace               : '$SM_MR_NS
echo 'Remote Cluster Name                        : '$CLUSTER_NAME
echo 'Remote Service Route                       : '$REMOTE_SERVICE_ROUTE
echo 'Greting Service Route Cert Secret Name     : '$CERTIFICATE_SECRET_NAME
echo '---------------------------------------------------------------------------'

oc new-project $SM_MR_NS
oc project  $SM_MR_NS

sleep 5

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
      name: https-web
      protocol: HTTPS
    tls:
      credentialName: $CERTIFICATE_SECRET_NAME #eg. greeting-remote-secret
      mode: MUTUAL
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
