#!/bin/bash

ISTIO_NAMESPACE=$1

echo '-------------------------------------------------------------------------'
echo 'Certs Manager applied in Namespace         : '$ISTIO_NAMESPACE
echo '-------------------------------------------------------------------------'


echo "################# Subscription - cert-manager-operator #################"   
echo "
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: cert-manager-operator
  namespace: openshift-operators
spec:
  channel: stable
  installPlanApproval: Automatic
  name: cert-manager-operator
  source: certified-operators
  sourceNamespace: openshift-marketplace
  startingCSV: cert-manager-operator.v1.1.0" | oc apply -f - 

sleep 25s

echo "################# CertManager - instance #################"   
echo "
apiVersion: operator.cert-manager.io/v1alpha1
kind: CertManager
metadata:
  name: cert-manager
spec: {}" | oc apply -n $ISTIO_NAMESPACE -f -  


sleep 30s

echo "################# cert-manager - Issuer Configuration #################"   
oc apply -f certs-manager-self-signed-issuer.yaml



