#!/usr/bin/env bash

set -e

cd "${0%/*}/.."

echo "opening bash shell"
docker run -i -t -v /srv/touchpoints:/touchpoints touchpoints:v1.0 bash
