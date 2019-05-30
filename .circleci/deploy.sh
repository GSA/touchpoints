#!/usr/bin/env bash

if [ "${CIRCLE_BRANCH}" == "master" ]
then
  # Fail if anything within this script returns
  # a non-zero exit code
  set -e

  echo "Logging into cloud.gov"
  # Log into CF and push
  cf login -a $CF_API_ENDPOINT -u $CF_USERNAME -p $CF_PASSWORD -o $CF_ORG -s $CF_SPACE
  echo "Pushing to Demo..."
  cf v3-zdt-push touchpoints-demo
  echo "Push to Demo Complete."
else
  echo "Not on the master branch."
fi

if [ "${CIRCLE_BRANCH}" == "develop" ]
then
  # Fail if anything within this script returns
  # a non-zero exit code
  set -e

  echo "Deploying the 'deploy-from-circleci' branch to the Staging environment"

  echo "Logging into cloud.gov"
  # Log into CF and push
  cf login -a $CF_API_ENDPOINT -u $CF_USERNAME -p $CF_PASSWORD -o $CF_ORG -s $CF_SPACE
  echo "Pushing to Staging..."
  cf v3-zdt-push touchpoints-staging
  echo "Push to Staging Complete."
else
  echo "Not on the develop branch."
fi
