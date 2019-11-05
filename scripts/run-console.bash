#!/usr/bin/env bash

set -e

cd "${0%/*}/.."

echo "Opening rails console...."
docker run -i -t -v /srv/FlexUOMConverter:/FlexUOMConverter flexconv:v1.0 rails console
require 'uom_conversion'
