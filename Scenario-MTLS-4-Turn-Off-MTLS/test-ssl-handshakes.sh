#!/bin/bash

POD_NAME=$1

echo "oc rsh -c istio-proxy pod/$POD_NAME curl localhost:15000/stats |grep handshake"
echo
echo '--------------------------------------------------------------------------------------'
oc rsh -c istio-proxy pod/$POD_NAME curl localhost:15000/stats |grep handshake
echo '--------------------------------------------------------------------------------------'
