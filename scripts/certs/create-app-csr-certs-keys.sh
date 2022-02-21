#!/bin/bash

LOCATION_CONF=$1
CERTS_PREFIX=$2

echo '-------------------------------------------------------------------------'
echo 'Certificate Info File Location             : '$LOCATION_CONF
echo 'Certificate Files Prefix                   : '$CERTS_PREFIX
echo '-------------------------------------------------------------------------'



echo "Step2: Create CSR request for app $CERTS_PREFIX"
echo "openssl req -new -config $LOCATION_CONF -nodes -keyout $CERTS_PREFIX.key -out $CERTS_PREFIX.csr"

openssl req -new -config $LOCATION_CONF -nodes -keyout $CERTS_PREFIX-app.key -out $CERTS_PREFIX-app.csr
#openssl req -newkey rsa:4096 -nodes -keyout app-key.pem -out app-req.csr -subj “/C=FR/ST=France/L=Paris/OU=RedHat/CN=*.bookinfo.com/emailAddress=stkousso@redhat.com”

echo "Step3: Sign Application Certificate"
echo "openssl x509 -req -in $CERTS_PREFIX.csr -days 365 -CA ca-root.crt -CAkey ca-root.key -CAcreateserial -out $CERTS_PREFIX-app.crt"
openssl x509 -req -in $CERTS_PREFIX-app.csr -days 365 -CA ca-root.crt -CAkey ca-root.key -CAcreateserial -out $CERTS_PREFIX-app.crt
#openssl x509 -req -in app-req.csr -days 365 -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out app-cert.pem 
