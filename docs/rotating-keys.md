### Rotating Keys

Keys should be rotated at least every 6-12 months.

Keys should be rotated for the following application environments:

* Production
* Demo
* Staging
* Dev (if applicable)

And, keys should be rotated in CircleCI as well.

##### Show information about a Deployer Service

See all services

`cf services`

For Production:

`cf service touchpoints-prod-deployer`

`cf service-keys touchpoints-prod-deployer`

cf delete-service-key touchpoints-prod-deployer prod-deploy-key
cf create-service-key touchpoints-prod-deployer prod-deploy-key
cf service-key touchpoints-prod-deployer prod-deploy-key

For Staging & Demo:

`cf service touchpoints-staging-deployer`

`cf service-keys touchpoints-staging-deployer`

cf delete-service-key touchpoints-staging-deployer staging-deploy-key
cf create-service-key touchpoints-staging-deployer touchpoints-staging-deploy-key
cf service-key touchpoints-staging-deployer touchpoints-staging-deploy-key


### ----------------

cf service-keys touchpoints-prod-s3
cf create-service-key touchpoints-prod-s3 touchpoints-production-s3-key
cf service-key touchpoints-prod-s3 touchpoints-production-s3-key

#### For binding a service

cf unbind-service touchpoints touchpoints-prod-s3
cf bind-service touchpoints touchpoints-prod-s3

cf unbind-service touchpoints-production-sidekiq-worker touchpoints-prod-s3
cf bind-service touchpoints-production-sidekiq-worker touchpoints-prod-s3

## Circle CI Env Settings

Keys that require rotating are indicated with a `👈`.

```
CF_API_ENDPOINT	xxxx.gov
CF_ORG	xxxxtics
CF_PASSWORD	xxxx9012 👈
CF_PRODUCTION_SPACE_DEPLOYER_PASSWORD	xxxx1234 👈
CF_PRODUCTION_SPACE_DEPLOYER_USERNAME	xxxx5678 👈
CF_SPACE	xxxxing
CF_USERNAME	xxxx9012 👈
INDEX_URL	xxxxdex
LOGIN_GOV_CLIENT_ID	xxxxging
LOGIN_GOV_ENABLED	xxxxse
LOGIN_GOV_IDP_BASE_URL	xxxxgov/
LOGIN_GOV_PRIVATE_KEY	xxxx--\n 👈 this just needs to be a valid .pem value but should not be a Login.gov key used for any real environment. Thus, only needs to be set once, but not rotated.
LOGIN_GOV_REDIRECT_URI	xxxxback
REDIS_URL	xxxx79/1
S3_AWS_ACCESS_KEY_ID	xxxxty ℹ️ S3 uses placeholder values, but not actual values
S3_AWS_BUCKET_NAME	xxxxty
S3_AWS_HOST	xxxxty
S3_AWS_REGION	xxxxty
S3_AWS_SECRET_ACCESS_KEY	xxxxty
TOUCHPOINTS_ADMIN_EMAILS	xxxx.gov
TOUCHPOINTS_EMAIL_SENDER	xxxx.gov
TOUCHPOINTS_GTM_CONTAINER_ID	xxxx59QD
TOUCHPOINTS_WEB_DOMAIN	xxxx.0.1
```
