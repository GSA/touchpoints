#!/usr/bin/env bash

set -e

cd "${0%/*}/.."

echo "Running app locally at http://localhost:3000"
docker run -i -t -p 3000:3000 -v /srv/touchpoints:/touchpoints touchpoints:v1.0 rails s -b 0.0.0.0
