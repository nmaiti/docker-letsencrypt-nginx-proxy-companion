#!/bin/bash

###################################################################
# Script Name : ci.sh
#
# Description :
#
# Args :
#
# Creation Date : 28-11-2020
# Last Modified :
#
# Created By : Nabendu
###################################################################
#!/bin/bash

if [ "$TRAVIS_PULL_REQUEST" = "true" ] || [ "$TRAVIS_BRANCH" != "acme.sh-pini" ]; then
  docker buildx build \
    --progress plain \
    --platform=linux/386,linux/amd64,linux/arm/v7,linux/arm/v6,linux/arm64,linux/ppc64le,linux/s390x \
    .
  exit $?
fi
echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERID --password-stdin &> /dev/null
TAG="${TRAVIS_TAG:-latest}"
docker buildx build \
  --progress plain \
  --platform=linux/386,linux/amd64,linux/arm/v7,linux/arm/v6,linux/arm64,linux/ppc64le,linux/s390x \
  -t $DOCKER_USERID/$DOCKER_REPO:$TAG \
  --push \
  .

