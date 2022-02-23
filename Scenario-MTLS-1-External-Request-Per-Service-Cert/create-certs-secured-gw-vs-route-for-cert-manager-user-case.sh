#!/bin/bash

NAMESPACE=$1
ISTIO_NAMESPACE=$2
HOSTNAME=$2
SECRET_NAME=$4

echo '-------------------------------------------------------------------------'
echo 'application namespace      : '$NAMESPACE
echo 'application hostname       : '$HOSTNAME
echo 'secret to stor certifcate  : '$SECRET_NAME
echo 'istio namespace      	 : '$ISTIO_NAMESPACE
echo '-------------------------------------------------------------------------'

echo "################# Create - Certificate for hostname [$HOSTNAME] with cert-manager and store in secret [$SECRET_NAME] #################" 

echo "apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: hello-openshift-cert
spec:
  secretName: $SECRET_NAME
  commonName: $HOSTNAME
  issuerRef:
    name: selfsigned-issuer
    kind: ClusterIssuer    
  dnsNames:
  - $HOSTNAME" | oc apply $ISTIO_NAMESPACE -f - 

sleep 5

echo "################# Create - Gateway to define HTTPS certificate [$SECRET_NAME] for hostname [$HOSTNAME] #################" 

echo "apiVersion: networking.istio.io/v1alpha3
	kind: Gateway
	metadata:
	  name: hello-openshift-gateway
	spec:
	  selector:
	    istio: ingressgateway
	  servers:
	  - port:
	      number: 443
	      name: https
	      protocol: HTTPS
	    tls:
	      mode: SIMPLE
	      credentialName: $SECRET_NAME
	    hosts:
	    - $HOSTNAME" | oc apply -n $NAMESPACE -f - 

sleep 5

echo "################# Create - VirtualService for host [$HOSTNAME] to service [hello-openshift.$NAMESPACE .svc.cluster.local] #################" 

echo "apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: hello-openshift
spec:
  gateways:
  - hello-openshift-gateway
  - mesh
  hosts:
  - $HOSTNAME
  http:
  - match:
    - uri:
	exact: /
    route:
    - destination:
	host: hello-openshift.$NAMESPACE.svc.cluster.local
	port:
	  number: 8080" | oc apply -n $NAMESPACE  -f - 

sleep 5

echo "################# Create - Route for host [$HOSTNAME] to expose service hello-openshift over https with cert-manager certifcate #################" 

echo "kind: Route
apiVersion: route.openshift.io/v1
metadata:
  name: hello-ocp
spec:
  host: hello-ocp.com
  to:
    kind: Service
    name: istio-ingressgateway
    weight: 100
  port:
    targetPort: https
  tls:
    termination: passthrough
  wildcardPolicy: None" | oc apply -n $ISTIO_NAMESPACE -f -




















