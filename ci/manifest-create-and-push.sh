#!/bin/bash

# ------------------------------------
#  ____   __   ____   __   _  _  ____ 
# (  _ \ / _\ (  _ \ / _\ ( \/ )/ ___)
#  ) __//    \ )   //    \/ \/ \\___ \
# (__)  \_/\_/(__\_)\_/\_/\_)(_/(____/
# ------------------------------------

# This script requires you to have a few environment variables set. As this is targeted
# to be used in a CICD environment, you should set these either via the Jenkins/Travis
# web-ui or in the `.travis.yml` or `pipeline` file respectfully 

# DOCKER_USER - Used for `docker login` to the private registry DOCKER_REGISTRY
# DOCKER_PASS - Password for the DOCKER_USER
# DOCKER_REGISTRY - Docker Registry to push the docker image and manifest to
# DOCKER_IMAGE - Name of the docker image

# Only build on master branch and NOT PR
if [[ "$TRAVIS_BRANCH" == "master" ]] && [[ "$TRAVIS_PULL_REQUEST" == "false" ]]; then 
    
    # ------------------------------
    #  ____  ____  ____  _  _  ____ 
    # / ___)(  __)(_  _)/ )( \(  _ \
    # \___ \ ) _)   )(  ) \/ ( ) __/
    # (____/(____) (__) \____/(__)  
    # ------------------------------
    
    DOCKER_TAG=$TRAVIS_BUILD_ID # A unique tag for our docker image

    # This uses DOCKER_USER and DOCKER_PASS to login to DOCKER_REGISTRY
    make docker:login

    # Pull each of our docker images
    docker pull $DOCKER_REGISTRY/$DOCKER_IMAGE-s390x:$DOCKER_TAG && \
    docker pull $DOCKER_REGISTRY/$DOCKER_IMAGE-amd64:$DOCKER_TAG && \
    docker pull $DOCKER_REGISTRY/$DOCKER_IMAGE-ppc64le:$DOCKER_TAG

    # ----------------------------------------------
    #  _  _   __   __ _  __  ____  ____  ____  ____ 
    # ( \/ ) / _\ (  ( \(  )(  __)(  __)/ ___)(_  _)
    # / \/ \/    \/    / )(  ) _)  ) _) \___ \  )(  
    # \_)(_/\_/\_/\_)__)(__)(__)  (____)(____/ (__) 
    # ----------------------------------------------

    # Create two manifests for our unique DOCKER_TAG and to update the "latest" image
    docker manifest create $DOCKER_REGISTRY/$DOCKER_IMAGE:$DOCKER_TAG \
    $DOCKER_REGISTRY/$DOCKER_IMAGE-s390x:$DOCKER_TAG \
    $DOCKER_REGISTRY/$DOCKER_IMAGE-amd64:$DOCKER_TAG \
    $DOCKER_REGISTRY/$DOCKER_IMAGE-ppc64le:$DOCKER_TAG

    docker manifest create $DOCKER_REGISTRY/$DOCKER_IMAGE:latest \
    $DOCKER_REGISTRY/$DOCKER_IMAGE-s390x:$DOCKER_TAG \
    $DOCKER_REGISTRY/$DOCKER_IMAGE-amd64:$DOCKER_TAG \
    $DOCKER_REGISTRY/$DOCKER_IMAGE-ppc64le:$DOCKER_TAG

    # Update the MetaData of the Manifest object
    docker manifest annotate $DOCKER_REGISTRY/$DOCKER_IMAGE:latest $DOCKER_REGISTRY/$DOCKER_IMAGE-s390x:$DOCKER_TAG --arch s390x && \
    docker manifest annotate $DOCKER_REGISTRY/$DOCKER_IMAGE:latest $DOCKER_REGISTRY/$DOCKER_IMAGE-ppc64le:$DOCKER_TAG --arch ppc64le && \
    docker manifest annotate $DOCKER_REGISTRY/$DOCKER_IMAGE:latest $DOCKER_REGISTRY/$DOCKER_IMAGE-amd64:$DOCKER_TAG --arch amd64 && \
    docker manifest annotate $DOCKER_REGISTRY/$DOCKER_IMAGE:$DOCKER_TAG $DOCKER_REGISTRY/$DOCKER_IMAGE-s390x:$DOCKER_TAG --arch s390x && \
    docker manifest annotate $DOCKER_REGISTRY/$DOCKER_IMAGE:$DOCKER_TAG $DOCKER_REGISTRY/$DOCKER_IMAGE-ppc64le:$DOCKER_TAG --arch ppc64le && \
    docker manifest annotate $DOCKER_REGISTRY/$DOCKER_IMAGE:$DOCKER_TAG $DOCKER_REGISTRY/$DOCKER_IMAGE-amd64:$DOCKER_TAG --arch amd64 && \
    
    # Push our two docker manifests to DOCKER_REGISTRY
    docker manifest push $DOCKER_REGISTRY/$DOCKER_IMAGE:$DOCKER_TAG
    docker manifest push $DOCKER_REGISTRY/$DOCKER_IMAGE:latest
fi