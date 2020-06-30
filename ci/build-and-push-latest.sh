if [[ "$TRAVIS_BRANCH" == "master" ]] && [[ "$TRAVIS_PULL_REQUEST" == "false" ]]; then 
    make docker:build && \
    make docker:login && \
    make docker:tag && \
    make docker:push
fi