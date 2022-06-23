#!/bin/bash
set -e

rubocop -A app
rubocop -A spec
