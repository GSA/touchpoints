#!/usr/bin/env bash

set -e

cd "${0%/*}/.."

echo "building docker image for development"
docker build . -t touchpoints:v1.0
