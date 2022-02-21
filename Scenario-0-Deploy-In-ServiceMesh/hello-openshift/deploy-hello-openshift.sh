#!/bin/bash

NAMESPACE=$1

echo '-------------------------------------------------------------------------'
echo 'hello-openshift deployed in namespace      : '$NAMESPACE
echo '-------------------------------------------------------------------------'

echo "################# Deployment - hello-openshift [$NAMESPACE] #################"             
echo "apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-openshift
  labels:
    app: hello-openshift
    version: 1.0.0
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hello-openshift
  template:
    metadata:
      annotations:
        sidecar.istio.io/inject: 'true'
      labels:
        app: hello-openshift
        version: 1.0.0        
    spec:
      containers:
      - name: hello-openshift
        image: openshift/hello-openshift:latest
        ports:
        - containerPort: 8080
          protocol: TCP
        - containerPort: 8888
          protocol: TCP" | oc apply -n $NAMESPACE -f -

echo "################# Service - hello-openshift [$NAMESPACE] #################"             
echo "apiVersion: v1
kind: Service
metadata:
  name: hello-openshift
  labels:
    app: hello-openshift
    app.kubernetes.io/name: hello-openshift
    version: 1.0.0
spec:
  ports:
  - name: 8080-tcp
    protocol: TCP
    port: 8080
    targetPort: 8080
  - name: 8888-tcp
    protocol: TCP
    port: 8888
    targetPort: 8888
  selector:
    app: hello-openshift" | oc apply -n $NAMESPACE -f -
    
echo "################# Route - hello-openshift [istio-system] #################"   
echo "kind: Route
apiVersion: route.openshift.io/v1
metadata:
  name: hello-openshift
  namespace: istio-system
spec:
  host: hello.openshift.com
  to:
    kind: Service
    name: istio-ingressgateway
    weight: 100
  port:
    targetPort: http
  wildcardPolicy: None" | oc apply -f -  
