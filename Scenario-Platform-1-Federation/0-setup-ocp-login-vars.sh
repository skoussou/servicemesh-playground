#!/bin/bash

export OCP_1_LOGIN_TOKEN=<TOKEN CLUSTER 1>
export OCP_1_LOGIN_SERVER=<API URL CLUSTER 1>

export OCP_2_LOGIN_TOKEN=<TOKEN CLUSTER 2>
export OCP_2_LOGIN_SERVER=<API URL CLUSTER 2>


echo
echo '---------------------------------------------------------------------------'
echo 'OCP_1_LOGIN_TOKEN  (EAST)       : '$OCP_1_LOGIN_TOKEN
echo 'OCP_1_LOGIN_SERVER (EAST)       : '$OCP_1_LOGIN_SERVER
echo '---------------------------------------------------------------------------'
echo 'OCP_2_LOGIN_TOKEN  (WEST)       : '$OCP_2_LOGIN_TOKEN
echo 'OCP_2_LOGIN_SERVER (WEST)       : '$OCP_2_LOGIN_SERVER
echo '---------------------------------------------------------------------------'
echo
