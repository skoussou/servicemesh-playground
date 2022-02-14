#!/bin/bash

echo "Step1: Create CA Key & Certificate (Done once)"
echo "openssl req -x509 -newkey rsa:4096 -days 365 -nodes -keyout ca-root.key -out ca-root.crt -subj "/C=UK/ST=Farnborough/L=Hampshire/OU=skousou/CN=skoussou.com/emailAddress=skousou@gmail.com""
openssl req -x509 -newkey rsa:4096 -days 365 -nodes -keyout ca-root.key -out ca-root.crt -subj "/C=UK/ST=Farnborough/L=Hampshire/OU=skousou/CN=skoussou.com/emailAddress=skousou@gmail.com"
