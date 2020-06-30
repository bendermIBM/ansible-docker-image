if [[ "$TRAVIS_BRANCH" == "master" ]] && [[ "$TRAVIS_PULL_REQUEST" == "false" ]]; then 
    make docker:build && \
    make docker:login && \
    make docker:tag && \
    make docker:push
fi

if [[ "$TRAVIS_PULL_REQUEST" == "true" ]]; then 
    export DOCKER_BUILD_TAG=$DOCKER_BUILD_TAG-pr && \
    make docker:build && \
    make docker:login && \
    make docker:tag && \
    make docker:push
fi