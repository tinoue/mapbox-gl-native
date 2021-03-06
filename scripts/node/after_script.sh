#!/bin/bash

set -e
set -o pipefail

# Inspect binary.
if [[ ${TRAVIS_OS_NAME} == "linux" ]]; then
    ldd ./lib/mapbox-gl-native.node
else
    otool -L ./lib/mapbox-gl-native.node
fi

COMMIT_MESSAGE=$(git show -s --format=%B $TRAVIS_COMMIT | tr -d '\n')

if test "${COMMIT_MESSAGE#*'[publish binary]'}" != "$COMMIT_MESSAGE"; then
    source ~/.nvm/nvm.sh
    nvm use $NODE_VERSION

    npm install aws-sdk

    ./node_modules/.bin/node-pre-gyp package

    if [[ ${TRAVIS_OS_NAME} == "linux" ]]; then
        ./node_modules/.bin/node-pre-gyp testpackage
    fi

    ./node_modules/.bin/node-pre-gyp publish info

    if [[ ${TRAVIS_OS_NAME} == "linux" ]]; then
        source ./scripts/${TRAVIS_OS_NAME}/setup.sh

        rm -rf build
        rm -rf lib
        npm install --fallback-to-build=false
        npm test
    fi
fi
