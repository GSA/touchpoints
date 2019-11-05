#!/usr/bin/env bash

set -e

cd "${0%/*}/.."

echo "Running tests"
docker run -i  -v /srv/FlexUOMConverter:/FlexUOMConverter flexconv:v1.0 rspec
