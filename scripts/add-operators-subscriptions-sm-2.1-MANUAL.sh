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
  channel: "4.6"
  installPlanApproval: Manual
  name: elasticsearch-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  startingCSV: elasticsearch-operator.4.6.0-202110262229
'

echo 'apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: elasticsearch-operator
spec:
  channel: "4.6"
  installPlanApproval: Manual
  name: elasticsearch-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  startingCSV: elasticsearch-operator.4.6.0-202110262229' | oc apply -f -  


echo 'sleeping 20s'
sleep 20

echo "################# Adding Operator jaeger-product #################"   
echo "
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: jaeger-product
  namespace: openshift-operators
spec:
  channel: stable
  installPlanApproval: Manual
  name: jaeger-product
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  startingCSV: jaeger-operator.v1.24.1
"

echo "apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: jaeger-product
  namespace: openshift-operators
spec:
  channel: stable
  installPlanApproval: Manual
  name: jaeger-product
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  startingCSV: jaeger-operator.v1.24.1" | oc apply -f -    

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
  installPlanApproval: Manual
  name: kiali-ossm
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  startingCSV: kiali-operator.v1.36.5
"

echo "apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: kiali-ossm
  namespace: openshift-operators
spec:
  channel: stable
  installPlanApproval: Manual
  name: kiali-ossm
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  startingCSV: kiali-operator.v1.36.5" | oc apply -f -   

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
  installPlanApproval: Manual
  name: servicemeshoperator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  startingCSV: servicemeshoperator.v2.1.0 
"

echo "apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: servicemeshoperator
  namespace: openshift-operators
spec:
  channel: stable
  installPlanApproval: Manual
  name: servicemeshoperator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  startingCSV: servicemeshoperator.v2.1.0" | oc apply -f -      
