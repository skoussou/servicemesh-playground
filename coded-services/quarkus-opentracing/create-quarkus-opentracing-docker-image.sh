#!/bin/bash

QUAYIO_USERNAME=$1
IMAGE_VERSION=$2

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
podman build -f src/main/docker/Dockerfile.jvm -t $QUAYIO_USERNAME/quarkus-opentracing .
echo
echo
echo "podman tag localhost/$QUAYIO_USERNAME/quarkus-opentracing $QUAYIO_USERNAME/quarkus-opentracing:v$IMAGE_VERSION"
podman tag localhost/$QUAYIO_USERNAME/quarkus-opentracing $QUAYIO_USERNAME/quarkus-opentracing:v$IMAGE_VERSION
echo
echo
echo '---------------------------------------------------------------------------'
echo ' skopeo login quay.io if necessary to get push the image  '
echo '----------------------------------------------------------------------------'
//echo "sudo skopeo copy --dest-tls-verify=false localhost/$QUAYIO_USERNAME/quarkus-opentracing:v$IMAGE_VERSION docker://quay.io/$QUAYIO_USERNAME/quarkus-opentracing:v$IMAGE_VERSION"
//sudo skopeo copy --dest-tls-verify=false containers-storage:localhost/$QUAYIO_USERNAME/quarkus-opentracing:v$IMAGE_VERSION docker://quay.io/$QUAYIO_USERNAME/quarkus-opentracing:v$IMAGE_VERSION
echo "skopeo copy --dest-tls-verify=false localhost/$QUAYIO_USERNAME/quarkus-opentracing:v$IMAGE_VERSION docker://quay.io/$QUAYIO_USERNAME/quarkus-opentracing:v$IMAGE_VERSION"
skopeo copy --dest-tls-verify=false containers-storage:localhost/$QUAYIO_USERNAME/quarkus-opentracing:v$IMAGE_VERSION docker://quay.io/$QUAYIO_USERNAME/quarkus-opentracing:v$IMAGE_VERSION

