#!/bin/bash

QUAYIO_USERNAME=$1
#SM_TENANT_NAME=$2
#SM_MR_NS=$3
#SM_REMOTE_ROUTE=$4

#echo
#echo '---------------------------------------------------------------------------'
#echo 'ServiceMesh Control Plane Namespace        : '$SM_CP_NS
#echo 'ServiceMesh Control Plane Tenant Name      : '$SM_TENANT_NAME
#echo 'ServiceMesh Member Namespace               : '$SM_MR_NS
#echo 'Remote SMCP Route Name                     : '$SM_REMOTE_ROUTE
#echo '---------------------------------------------------------------------------'
#echo

echo
echo '---------------------------------------------------------------------------'
echo 'mvn package'
mvn package
echo
echo '---------------------------------------------------------------------------'
echo ' podman login registry.redhat.io if necessary to get access to ubi image   '
echo '---------------------------------------------------------------------------'
echo
echo "podman build -f src/main/docker/Dockerfile.jvm -t $QUAYIO_USERNAME/quarkus-opentracing ."
echo podman build -f src/main/docker/Dockerfile.jvm -t $QUAYIO_USERNAME/quarkus-opentracing .
echo
echo
echo "podman tag localhost/$QUAYIO_USERNAME/quarkus-opentracing $QUAYIO_USERNAME/quarkus-opentracing:v1.0.0"
podman tag localhost/$QUAYIO_USERNAME/quarkus-opentracing $QUAYIO_USERNAME/quarkus-opentracing:v1.0.0
echo
echo
echo '---------------------------------------------------------------------------'
echo ' skopeo login quay.io if necessary to get push the image  '
echo '----------------------------------------------------------------------------'
echo "sudo skopeo copy --dest-tls-verify=false localhost/$QUAYIO_USERNAME/quarkus-opentracing:v1.0.0 docker://quay.io/$QUAYIO_USERNAME/quarkus-opentracing"
sudo skopeo copy --dest-tls-verify=false containers-storage:localhost/$QUAYIO_USERNAME/quarkus-opentracing:v1.0.0 docker://quay.io/$QUAYIO_USERNAME/quarkus-opentracing




