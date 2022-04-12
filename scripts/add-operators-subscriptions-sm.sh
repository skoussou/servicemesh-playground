#!/bin/bash

echo "oc create ns openshift-operators-redhat"   
oc create ns openshift-operators-redhat
sleep 4
echo "################# Adding Operator elasticsearch-operator #################"   
echo '
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: elasticsearch-operator
  namespace: openshift-operators-redhat
spec:
  channel: stable-5.3
  installPlanApproval: Automatic
  name: elasticsearch-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
' | oc apply -f -  

echo 'apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: elasticsearch-operator
  namespace: openshift-operators-redhat
spec:
  channel: stable-5.3
  installPlanApproval: Automatic
  name: elasticsearch-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace" | oc apply -f -  

echo 'sleeping 20s'
sleep 20

operators.coreos.com/jaeger-product.openshift-operators

echo "################# Adding Operator jaeger-product #################"   
echo "
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: jaeger-product
  namespace: openshift-operators
spec:
  channel: stable
  installPlanApproval: Automatic
  name: jaeger-product
  source: redhat-operators
  sourceNamespace: openshift-marketplace
"

echo "apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: jaeger-product
  namespace: openshift-operators
spec:
  channel: stable
  installPlanApproval: Automatic
  name: jaeger-product
  source: redhat-operators
  sourceNamespace: openshift-marketplace" | oc apply -f -    

echo 'sleeping 20s'
sleep 20

echo "################# Adding Operator kiali-ossm #################"   
echo "
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: kiali-ossm
  namespace: openshift-operators  
spec:
  channel: stable
  installPlanApproval: Automatic
  name: kiali-ossm
  source: redhat-operators
  sourceNamespace: openshift-marketplace
"

echo "apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: kiali-ossm
  namespace: openshift-operators  
spec:
  channel: stable
  installPlanApproval: Automatic
  name: kiali-ossm
  source: redhat-operators
  sourceNamespace: openshift-marketplace" | oc apply -f -   

echo 'sleeping 20s'
sleep 20


echo "################# Adding Operator servicemeshoperator #################"   
echo "
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: servicemeshoperator
  namespace: openshift-operators
spec:
  channel: stable
  installPlanApproval: Automatic
  name: servicemeshoperator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
"

echo "apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: servicemeshoperator
  namespace: openshift-operators
spec:
  channel: stable
  installPlanApproval: Automatic
  name: servicemeshoperator
  source: redhat-operators
  sourceNamespace: openshift-marketplace" | oc apply -f -      
