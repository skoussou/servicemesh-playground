#!/bin/bash


FED_1_SMCP_NAMESPACE=remote-east-mesh-system
FED_1_SMCP_NAME=east-mesh
FED_2_SMCP_NAMESPACE=remote-west-mesh-system
FED_2_SMCP_NAME=west-mesh

echo
echo
echo
echo
echo 'Starting Federation Setup ...'
echo
sleep 2
echo
echo '---------------------------------------------------------------------------'
echo 'Federated ServiceMesh Control Plane 1 Namespace        : '$FED_1_SMCP_NAMESPACE
echo 'Federated ServiceMesh Control Plane 1 Tenant Name      : '$FED_1_SMCP_NAME
echo 'Federated ServiceMesh Control Plane 2 Namespace        : '$FED_2_SMCP_NAMESPACE
echo 'Federated ServiceMesh Control Plane 2 Tenant Name      : '$FED_2_SMCP_NAME
echo '---------------------------------------------------------------------------'
echo

. 0-setup-ocp-login-vars.sh
echo
echo '########################################################################################################################'
echo '#                                                                                                                      #'
echo '#   STAGE 1 - Setup Namespaces, ServiceMeshControlPlane (SMCP), ServiceMeshMemberRole (SMMR), Dataplane Namespaces     #'
echo '#                                                                                                                      #'
echo '########################################################################################################################'
echo
sleep 4
echo "---------------------- Step 1-a - Creation of EAST-MESH SMCP Namespace [$FED_1_SMCP_NAMESPACE], SMCP Resource  [$FED_1_SMCP_NAME], SMMR Resources  ----------------------"
sleep 7
echo
echo
echo "LOGIN CLUSTER 1 [EAST]: oc login --server=$OCP_1_LOGIN_SERVER"
oc login --token=$OCP_1_LOGIN_TOKEN --server=$OCP_1_LOGIN_SERVER
echo
#echo "
#kind: Project
#apiVersion: project.openshift.io/v1
#metadata:
#  name: ${FED_1_SMCP_NAMESPACE} |oc apply -f -"
  
echo "
kind: Project
apiVersion: project.openshift.io/v1
metadata:
  name: ${FED_1_SMCP_NAMESPACE}" |oc apply -f -  
sleep 3
echo 
echo "
apiVersion: maistra.io/v2
kind: ServiceMeshControlPlane
metadata:
  name: $FED_1_SMCP_NAME
  namespace: ${FED_1_SMCP_NAMESPACE}
spec:
  version: v2.1
  runtime:
    defaults:
      container:
        imagePullPolicy: Always
  gateways:
    additionalEgress:
      egress-west-mesh:
        enabled: true
        requestedNetworkView:
        - network-west-mesh
        routerMode: sni-dnat
        service:
          metadata:
            labels:
              federation.maistra.io/proxy: egress-west-mesh
          ports:
          - port: 15443
            name: tls
          - port: 8188
            name: http-discovery
    additionalIngress:
      ingress-west-mesh:
        enabled: true
        routerMode: sni-dnat
        service:
          type: LoadBalancer
          metadata:
            labels:
              federation.maistra.io/proxy: ingress-west-mesh
          ports:
          - port: 15443
            name: tls
          - port: 8188
            name: https-discovery     
  security:
    trust:
      domain: $FED_1_SMCP_NAME.local |oc apply -f -"
      
echo "
apiVersion: maistra.io/v2
kind: ServiceMeshControlPlane
metadata:
  name: $FED_1_SMCP_NAME
  namespace: ${FED_1_SMCP_NAMESPACE}
spec:
  version: v2.1
  runtime:
    defaults:
      container:
        imagePullPolicy: Always
  gateways:
    additionalEgress:
      egress-west-mesh:
        enabled: true
        requestedNetworkView:
        - network-west-mesh
        routerMode: sni-dnat
        service:
          metadata:
            labels:
              federation.maistra.io/proxy: egress-west-mesh
          ports:
          - port: 15443
            name: tls
          - port: 8188
            name: http-discovery
    additionalIngress:
      ingress-west-mesh:
        enabled: true
        routerMode: sni-dnat
        service:
          type: LoadBalancer
          metadata:
            annotations:
              service.beta.kubernetes.io/aws-load-balancer-type: nlb            
            labels:
              federation.maistra.io/proxy: ingress-west-mesh
          ports:
          - port: 15443
            name: tls
          - port: 8188
            name: https-discovery     
  security:
    trust:
      domain: $FED_1_SMCP_NAME.local" |oc apply -f -      
      
sleep 6
echo 
echo "
apiVersion: maistra.io/v1
kind: ServiceMeshMemberRoll
metadata:
  name: default
  namespace: ${FED_1_SMCP_NAMESPACE}
spec:
  members:
  - east-travel-agency
  - east-travel-portal
  - east-travel-control |oc apply -f -"  
  
echo "
apiVersion: maistra.io/v1
kind: ServiceMeshMemberRoll
metadata:
  name: default
  namespace: ${FED_1_SMCP_NAMESPACE}
spec:
  members:
  - east-travel-agency
  - east-travel-portal
  - east-travel-control" |oc apply -f -     

echo 
echo
echo "oc wait --for condition=Ready -n $FED_1_SMCP_NAMESPACE smcp/$FED_1_SMCP_NAME --timeout 300s"
#oc wait --for condition=Ready -n $FED_1_SMCP_NAMESPACE smcp/$FED_1_SMCP_NAME --timeout 300s
sleep 15
echo
echo
echo '---------------------- Step 1-b - Creation of EAST-MESH - Dataplane namespaces  ----------------------'
sleep 4
echo 'oc create namespace east-travel-agency'
oc create namespace east-travel-agency
echo 'oc create namespace east-travel-portal'
oc create namespace east-travel-portal
echo 'oc create namespace east-travel-control'
oc create namespace east-travel-control

sleep 10

echo "oc wait --for condition=Ready -n $FED_1_SMCP_NAMESPACE smmr/default --timeout 300s"
#oc wait --for condition=Ready -n $FED_1_SMCP_NAMESPACE smmr/default --timeout 300s
echo
echo
echo "---------------------- Step 1-c - Creation of WEST-MESH SMCP Namespace [$FED_2_SMCP_NAMESPACE], SMCP Resource  [$FED_2_SMCP_NAME], SMMR Resources ----------------------"
sleep 7
echo
echo "LOGIN CLUSTER 2 [WEST]: oc login --server=$OCP_2_LOGIN_SERVER"
oc login --token=$OCP_2_LOGIN_TOKEN --server=$OCP_2_LOGIN_SERVER
echo
#echo "
#kind: Project
#apiVersion: project.openshift.io/v1
#metadata:
#  name: ${FED_2_SMCP_NAMESPACE} |oc apply -f -"
echo "
kind: Project
apiVersion: project.openshift.io/v1
metadata:
  name: ${FED_2_SMCP_NAMESPACE}" |oc apply -f -  
sleep 3
echo 
echo "
apiVersion: maistra.io/v2
kind: ServiceMeshControlPlane
metadata:
  name: $FED_2_SMCP_NAME
  namespace: ${FED_2_SMCP_NAMESPACE} 
spec:
  version: v2.1
  runtime:
    defaults:
      container:
        imagePullPolicy: Always
  gateways:
    additionalEgress:
      egress-east-mesh:
        enabled: true
        requestedNetworkView:
        - network-east-mesh
        routerMode: sni-dnat
        service:
          metadata:
            labels:
              federation.maistra.io/proxy: egress-east-mesh
          ports:
          - port: 15443
            name: tls
          - port: 8188
            name: http-discovery
    additionalIngress:
      ingress-east-mesh:
        enabled: true
        routerMode: sni-dnat
        service:
          type: LoadBalancer
          metadata:
            annotations:
              service.beta.kubernetes.io/aws-load-balancer-type: nlb            
            labels:
              federation.maistra.io/proxy: ingress-east-mesh
          ports:
          - port: 15443
            name: tls
          - port: 8188
            name: https-discovery     
  security:
    trust:
      domain: $FED_2_SMCP_NAME.local |oc apply -f -"
echo "
apiVersion: maistra.io/v2
kind: ServiceMeshControlPlane
metadata:
  name: $FED_2_SMCP_NAME
  namespace: ${FED_2_SMCP_NAMESPACE} 
spec:
  version: v2.1
  runtime:
    defaults:
      container:
        imagePullPolicy: Always
  gateways:
    additionalEgress:
      egress-east-mesh:
        enabled: true
        requestedNetworkView:
        - network-east-mesh
        routerMode: sni-dnat
        service:
          metadata:
            labels:
              federation.maistra.io/proxy: egress-east-mesh
          ports:
          - port: 15443
            name: tls
          - port: 8188
            name: http-discovery
    additionalIngress:
      ingress-east-mesh:
        enabled: true
        routerMode: sni-dnat
        service:
          type: LoadBalancer
          metadata:
            annotations:
              service.beta.kubernetes.io/aws-load-balancer-type: nlb            
            labels:
              federation.maistra.io/proxy: ingress-east-mesh
          ports:
          - port: 15443
            name: tls
          - port: 8188
            name: https-discovery     
  security:
    trust:
      domain: $FED_2_SMCP_NAME.local" |oc apply -f -      
echo
sleep 7
echo 
echo "
apiVersion: maistra.io/v1
kind: ServiceMeshMemberRoll
metadata:
  name: default
  namespace: ${FED_2_SMCP_NAMESPACE} 
spec:
  members:
  - west-travel-agency  |oc apply -f -"    
echo "
apiVersion: maistra.io/v1
kind: ServiceMeshMemberRoll
metadata:
  name: default
  namespace: ${FED_2_SMCP_NAMESPACE} 
spec:
  members:
  - west-travel-agency"  |oc apply -f -      
  
echo 
echo
echo "oc wait --for condition=Ready -n $FED_2_SMCP_NAMESPACE smcp/$FED_2_SMCP_NAME --timeout 300s"
oc wait --for condition=Ready -n $FED_2_SMCP_NAMESPACE smcp/$FED_2_SMCP_NAME --timeout 300s
sleep 10
echo
echo
echo '---------------------- Step 1-d - Creation of WEST-MESH - Dataplane namespaces  ----------------------'
sleep 7
echo 'oc create namespace west-travel-agency'
oc create namespace west-travel-agency
sleep 2

echo "oc wait --for condition=Ready -n $FED_2_SMCP_NAMESPACE smmr/default --timeout 300s"
oc wait --for condition=Ready -n $FED_2_SMCP_NAMESPACE smmr/default --timeout 300s
sleep 10
echo
echo
echo '###########################################################################'
echo '#                                                                         #'
echo '#   STAGE 2 - Create PEERING between meshes                               #'
echo '#                                                                         #'
echo '###########################################################################'
echo
sleep 5

echo '---------------------- Step 2 - Share root certs to validate each other client certs  ----------------------'
sleep 7
echo
echo "LOGIN CLUSTER 1 [EAST]: "
oc login --token=$OCP_1_LOGIN_TOKEN --server=$OCP_1_LOGIN_SERVER
echo
echo
echo '============='
echo 'EAST CLUSTER'
echo '============='
echo "a. GET CERT FROM REMOTE-EAST MESH:					oc get configmap istio-ca-root-cert -o jsonpath='{.data.root-cert\.pem}' -n $FED_1_SMCP_NAMESPACE > remote-east-mesh-cert.pem"
oc get configmap istio-ca-root-cert -o jsonpath='{.data.root-cert\.pem}' -n $FED_1_SMCP_NAMESPACE > remote-east-mesh-cert.pem
echo
echo
sleep 5
echo "LOGIN CLUSTER 2 [WEST]: "
oc login --token=$OCP_2_LOGIN_TOKEN --server=$OCP_2_LOGIN_SERVER
echo '============='
echo 'WEST CLUSTER'
echo '============='
echo
echo "b. CREATE IN WEST CLUSTER with REMOTE-EAST MESH CERT configmap:		oc create configmap east-ca-root-cert --from-file=root-cert.pem=remote-east-mesh-cert.pem -n $FED_2_SMCP_NAMESPACE"
oc create configmap east-ca-root-cert --from-file=root-cert.pem=remote-east-mesh-cert.pem -n $FED_2_SMCP_NAMESPACE
echo
echo
sleep 5
echo "c. GET CERT FROM REMOTE-WEST MESH:					oc get configmap istio-ca-root-cert -o jsonpath='{.data.root-cert\.pem}' -n $FED_2_SMCP_NAMESPACE > remote-west-mesh-cert.pem"
oc get configmap istio-ca-root-cert -o jsonpath='{.data.root-cert\.pem}' -n $FED_2_SMCP_NAMESPACE > remote-west-mesh-cert.pem
echo
sleep 5
echo "LOGIN CLUSTER 1 [EAST]: "
oc login --token=$OCP_1_LOGIN_TOKEN --server=$OCP_1_LOGIN_SERVER
echo
echo 
echo '============='
echo 'EAST CLUSTER'
echo '============='
echo
echo "d. CREATE IN WEST CLUSTER with REMOTE-EAST MESH CERT configmap:		oc create configmap west-ca-root-cert --from-file=root-cert.pem=remote-west-mesh-cert.pem -n $FED_1_SMCP_NAMESPACE"
oc create configmap west-ca-root-cert --from-file=root-cert.pem=remote-west-mesh-cert.pem -n $FED_1_SMCP_NAMESPACE
echo
echo
sleep 10
echo
echo '---------------------- Step 3 - Retrieve AWS/GCP LB Addresses to setup ServiceMeshPeering  ----------------------'
sleep 7
echo
echo "LOGIN CLUSTER 1 [EAST]: "
oc login --token=$OCP_1_LOGIN_TOKEN --server=$OCP_1_LOGIN_SERVER
echo
echo
echo 'Getting LB ip address of ingress-west-mesh on EAST side to be used on WEST side ServiceMeshPeeer'
GCP_LB_SM_1=$(oc get svc ingress-west-mesh -o jsonpath='{.status.loadBalancer.ingress[0].ip}' -n $FED_1_SMCP_NAMESPACE)
echo "[EAST OCP GCP LB] $GCP_LB_SM_1"
sleep 7
echo
echo "LOGIN CLUSTER 2 [WEST]: "
oc login --token=$OCP_2_LOGIN_TOKEN --server=$OCP_2_LOGIN_SERVER
echo
echo 'Getting LB address of ingress-east-mesh on WEST SIDE to be used on EAST side ServiceMeshPeeer'
AWS_LB_SM_2=$(oc get svc ingress-east-mesh -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' -n $FED_2_SMCP_NAMESPACE)
echo "[WEST OCP AWS LB] $AWS_LB_SM_2"
sleep 10
echo
echo
echo '---------------------- Step 4a - Setup Service Mesh Peering & Service Imports (EAST -> WEST)  ----------------------'
sleep 7
echo
echo "LOGIN CLUSTER 1 [EAST]: "
oc login --token=$OCP_1_LOGIN_TOKEN --server=$OCP_1_LOGIN_SERVER
echo
echo
echo "
kind: ServiceMeshPeer
apiVersion: federation.maistra.io/v1
metadata:
  name: $FED_2_SMCP_NAME
  namespace: $FED_1_SMCP_NAMESPACE
spec:
  remote:
    addresses:
    - ${AWS_LB_SM_2}
    discoveryPort: 8188
    servicePort: 15443
  gateways:
    ingress:
      name: ingress-west-mesh
    egress:
      name: egress-west-mesh
  security:
    trustDomain: $FED_2_SMCP_NAME.local
    clientID: $FED_2_SMCP_NAME.local/ns/$FED_2_SMCP_NAMESPACE/sa/egress-east-mesh-service-account
    certificateChain:
      kind: ConfigMap
      name: west-ca-root-cert |oc apply -f -"
echo "
kind: ServiceMeshPeer
apiVersion: federation.maistra.io/v1
metadata:
  name: $FED_2_SMCP_NAME
  namespace: $FED_1_SMCP_NAMESPACE
spec:
  remote:
    addresses:
    - ${AWS_LB_SM_2}
    discoveryPort: 8188
    servicePort: 15443
  gateways:
    ingress:
      name: ingress-west-mesh
    egress:
      name: egress-west-mesh
  security:
    trustDomain: $FED_2_SMCP_NAME.local
    clientID: $FED_2_SMCP_NAME.local/ns/$FED_2_SMCP_NAMESPACE/sa/egress-east-mesh-service-account
    certificateChain:
      kind: ConfigMap
      name: west-ca-root-cert" |oc apply -f -      
sleep 7
echo 
echo "
kind: ImportedServiceSet
apiVersion: federation.maistra.io/v1
metadata:
  name: $FED_2_SMCP_NAME
  namespace: $FED_1_SMCP_NAMESPACE
spec:
  importRules:
  - type: NameSelector
    nameSelector:
      importAsLocal: false
      namespace: travel-agency
      name: discounts |oc apply -f -"
echo "
kind: ImportedServiceSet
apiVersion: federation.maistra.io/v1
metadata:
  name: $FED_2_SMCP_NAME
  namespace: $FED_1_SMCP_NAMESPACE
spec:
  importRules:
  - type: NameSelector
    nameSelector:
      importAsLocal: false
      namespace: travel-agency
      name: discounts" |oc apply -f -      
sleep 12
echo
echo
echo '---------------------- Step 4b - Setup Service Mesh Peering & Service Exports (WEST -> EAST)  ----------------------'
sleep 7
echo
echo "LOGIN CLUSTER 2 [WEST]: "
oc login --token=$OCP_2_LOGIN_TOKEN --server=$OCP_2_LOGIN_SERVER
echo
echo
echo "
kind: ServiceMeshPeer
apiVersion: federation.maistra.io/v1
metadata:
  name: $FED_1_SMCP_NAME
  namespace: $FED_2_SMCP_NAMESPACE
spec:
  remote:
    addresses:
    - ${GCP_LB_SM_1}
    discoveryPort: 8188
    servicePort: 15443
  gateways:
    ingress:
      name: ingress-east-mesh
    egress:
      name: egress-east-mesh
  security:
    trustDomain: $FED_1_SMCP_NAME.local
    clientID: $FED_1_SMCP_NAME.local/ns/$FED_1_SMCP_NAMESPACE/sa/egress-west-mesh-service-account
    certificateChain:
      kind: ConfigMap
      name: east-ca-root-cert |oc apply -f -"
echo "
kind: ServiceMeshPeer
apiVersion: federation.maistra.io/v1
metadata:
  name: $FED_1_SMCP_NAME
  namespace: $FED_2_SMCP_NAMESPACE
spec:
  remote:
    addresses:
    - ${GCP_LB_SM_1}
    discoveryPort: 8188
    servicePort: 15443
  gateways:
    ingress:
      name: ingress-east-mesh
    egress:
      name: egress-east-mesh
  security:
    trustDomain: $FED_1_SMCP_NAME.local
    clientID: $FED_1_SMCP_NAME.local/ns/$FED_1_SMCP_NAMESPACE/sa/egress-west-mesh-service-account
    certificateChain:
      kind: ConfigMap
      name: east-ca-root-cert" |oc apply -f -      
sleep 7
echo 
echo "
kind: ExportedServiceSet
apiVersion: federation.maistra.io/v1
metadata:
  name: $FED_1_SMCP_NAME
  namespace: $FED_2_SMCP_NAMESPACE
spec:
  exportRules:  
  - type: NameSelector
    nameSelector:
      namespace: west-travel-agency
      name: discounts
      alias:
        namespace: travel-agency
        name: discounts |oc apply -f -"
echo "
kind: ExportedServiceSet
apiVersion: federation.maistra.io/v1
metadata:
  name: $FED_1_SMCP_NAME
  namespace: $FED_2_SMCP_NAMESPACE
spec:
  exportRules:  
  - type: NameSelector
    nameSelector:
      namespace: west-travel-agency
      name: discounts
      alias:
        namespace: travel-agency
        name: discounts" |oc apply -f -        
sleep 7
echo
echo
echo '---------------------- Step 4c - Verify Service Mesh Peering Connection (EAST -> WEST)  ----------------------'
sleep 7
echo
echo "LOGIN CLUSTER 1 [EAST]: "
oc login --token=$OCP_1_LOGIN_TOKEN --server=$OCP_1_LOGIN_SERVER
echo
echo 'Check if status \"connected: true\" 305 times with 1 sec delay as 5 mins peering synced'
echo "oc get servicemeshpeer $FED_2_SMCP_NAME -o jsonpath='{.status.discoveryStatus.active[0].watch.connected}' -n $FED_1_SMCP_NAMESPACE"
oc get servicemeshpeer $FED_2_SMCP_NAME -o jsonpath='{.status.discoveryStatus.active[0].watch.connected}{"\n"}' -n $FED_1_SMCP_NAMESPACE
sleep 5
echo
echo
echo '---------------------- Step 4d - Verify Service Mesh Peering Connection (WEST -> EAST)  ----------------------'
sleep 7
echo
echo "LOGIN CLUSTER 2 [WEST]: "
oc login --token=$OCP_2_LOGIN_TOKEN --server=$OCP_2_LOGIN_SERVER
echo
echo 'Check if status \"connected: true\" 305 times with 1 sec delay as 5 mins peering synced'
echo "oc get servicemeshpeer $FED_1_SMCP_NAME -o jsonpath='{.status.discoveryStatus.inactive[0].remotes[0].connected}' -n $FED_2_SMCP_NAMESPACE"
oc get servicemeshpeer $FED_1_SMCP_NAME -o jsonpath='{.status.discoveryStatus.inactive[0].remotes[0].connected}{"\n"}' -n $FED_2_SMCP_NAMESPACE
echo
sleep 5
echo
echo '###########################################################################'
echo '#                                                                         #'
echo '#   STAGE 3 - Deploy Applications                                         #'
echo '#                                                                         #'
echo '###########################################################################'
echo
sleep 5
echo "LOGIN CLUSTER 1 [EAST]: "
oc login --token=$OCP_1_LOGIN_TOKEN --server=$OCP_1_LOGIN_SERVER
echo
echo '============='
echo 'EAST CLUSTER'
echo '============'
echo 'oc apply -n east-travel-agency -f https://raw.githubusercontent.com/kiali/demos/master/federated-travels/east/east-travel-agency.yaml'
oc apply -n east-travel-agency -f https://raw.githubusercontent.com/kiali/demos/master/federated-travels/east/east-travel-agency.yaml
echo 'oc apply -n east-travel-portal -f https://raw.githubusercontent.com/kiali/demos/master/federated-travels/east/east-travel-portal.yaml'
oc apply -n east-travel-portal -f https://raw.githubusercontent.com/kiali/demos/master/federated-travels/east/east-travel-portal.yaml
echo 'oc apply -n east-travel-control -f https://raw.githubusercontent.com/kiali/demos/master/federated-travels/east/east-travel-control.yaml'
oc apply -n east-travel-control -f https://raw.githubusercontent.com/kiali/demos/master/federated-travels/east/east-travel-control.yaml
sleep 7
echo
echo "LOGIN CLUSTER 2 [WEST]: "
oc login --token=$OCP_2_LOGIN_TOKEN --server=$OCP_2_LOGIN_SERVER
echo
echo '============='
echo 'WEST CLUSTER'
echo '============='
echo 'oc apply -n west-travel-agency -f https://raw.githubusercontent.com/kiali/demos/master/federated-travels/west/west-travel-agency.yaml'
oc apply -n west-travel-agency -f https://raw.githubusercontent.com/kiali/demos/master/federated-travels/west/west-travel-agency.yaml
sleep 15        
echo
echo '###########################################################################'
echo '#                                                                         #'
echo '#   STAGE 4 - Check Federation status in KIALI Graphs                     #'
echo '#                                                                         #'
echo '###########################################################################'
echo        
echo
oc login --token=$OCP_1_LOGIN_TOKEN --server=$OCP_1_LOGIN_SERVER
echo
KIALI_1="http://$(oc get route kiali -o jsonpath='{.spec.host}' -n $FED_1_SMCP_NAMESPACE)"
echo "CLUSTER 1 [EAST]: KIALI ROUTE $KIALI_1" 
echo
oc login --token=$OCP_2_LOGIN_TOKEN --server=$OCP_2_LOGIN_SERVER
echo
KIALI_2="http://$(oc get route kiali -o jsonpath='{.spec.host}' -n $FED_2_SMCP_NAMESPACE)"
echo "CLUSTER 2 [WEST]: KIALI ROUTE $KIALI_2" 
        
        
        
        
        
