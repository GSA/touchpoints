# Deployment

This document provides explanation of
the Touchpoints agile development process
and the production deployment process.

---

Touchpoints is currently deployed in at least 3 environments.
 
| 1. [Staging](https://touchpoints-staging.app.cloud.gov) | updated multiple times daily. used for continually integrating in-development code |
1. [Demo](https://touchpoints-demo.app.cloud.gov) - a stable, longer-lived environment for Touchpoint's gov customers to test in. Demo may be used to preview a pre-release version of Touchpoints.
1. [Production](https://touchpoints.app.cloud.gov) - the live site

These environments are managed via [cloud.gov](https://cloud.gov),
and are currently configured to run on Cloud Foundry, but can run elsewhere with relatively little modification.

Each Developer is expected to
be able to develop Touchpoints on their own cloud.gov instance as well.

### How to Deploy Touchpoints

Deploying Touchpoints requires pushing a directory of code (the Touchpoints repo or CI build output) to an application instance in cloud.gov's Cloud Foundry using the `cf push` command.

This can be done 1) manually via command line or 2) in an automated way, using a [continuous integration](https://en.wikipedia.org/wiki/Continuous_integration) tool like CircleCI.

###### Using Cloud Foundry

`cf push` references a local `manifest.yml` that declares one or more applications.
Thus, having a "properly configured" `manifest.yml` file is a prerequisite dependency; a requirement.

To deploy a specific instance, use `cf push`.
For example: `cf push touchpoints-staging`.

## Touchpoints Development Process

Software Product teams develop conventions related to
the development process. The steps below represent the flow of code from a developer's machine through multiple gates, to production.

##### How git branches are used

* Code that is releasable lives in the `master` branch on GitHub
* Code that is in-development lives in the `develop` branch
* Developers work in feature-branches, created off the `develop` branch

##### How code flows from feature to develop to master

* LOCAL DEVELOPMENT
* feature branches are pushed to https://touchpoints-dev-name-of-dev.app.cloud.gov (each Dev has their own Dev environment)
* feature branches are submitted as Pull Requests and reviewed in GitHub
* all commits are pushed here, to this Touchpoints code repository
 * upon code commit, CircleCI runs automated tests
 * upon code commit, Snyk runs automated code scans
* When a feature branch is code reviewed and clicked-through on , it may be merged to `develop`
* When a story is completed and ready for Acceptance, a Developer pushes the `develop` or `feature` branch to the Staging environment
  * [ ] green (passing) master builds get deployed to [Staging](https://touchpoints-staging.app.cloud.gov) automatically via CircleCI
* ON STAGING...
* Product Owner accepts or rejects stories and/or features on the [Staging](https://touchpoints-staging.app.cloud.gov) environment.
* 👀 CODE REVIEW
* When stories in `develop` are Accepted by the Product Owner on Staging, they can be merged to `master` with the Team's discretion
* the `develop` branch is merged to `master` via Pull Request
  * [ ] green (passing) master builds get deployed to [Demo](https://touchpoints-demo.app.cloud.gov) automatically via CircleCI
* ON DEMO...
* Users can use the product and share feedback ➰ in a Demo environment
* CREATING A RELEASE:
* releases are tagged using semantic versioning. for example: `git tag 0.0.1`
* 🚢 TO PRODUCTION!
  * [ ] green (passing) master builds can be deployed to [Production](https://touchpoints.app.cloud.gov) by coordinating with [Ryan Wold](mailto:ryan.wold@gsa.gov)

### Environment variables

Touchpoints requires multiple environment variables to be setup for each application instance. Environment variables are conventionally set in `manifest.yml`. See `manifest.sample.yml` for an example.

Configuration values are to be set in the cloud.gov application instance as environment variables.

There is an audit trail for changing cloud.gov environment variables via the Cloud Foundry API. https://apidocs.cloudfoundry.org/253/events/list_user_provided_service_instance_update_events.html


| name     | description      | required | default |   |
|----------|------------------|:--------:|---------|:--|
| AWS_ACCESS_KEY_ID | IAM Account Key used for Simple email service | no | |
| AWS_SECRET_ACCESS_KEY | IAM Account Access Key used for Simple email service| no | |
| AWS_REGION | specifies AWS region | no | us-east-1 |
| GOOGLE_API_QUOTA_USER | 40 character string used to identify Google API requests | yes | TTS-GSA-TOUCHPOINTS-environment-user |
| GOOGLE_CONFIG | used for Google Drive, Sheets, Tag Manager APIs - a .json string | no | |
| GOOGLE_TAG_MANAGER_ACCOUNT_ID | 1 GTM Account per Touchpoints environment. This is the Account ID for the Google Tag Manager Account being used. Touchpoints creates all its Containers under a single Account. Note: different Account IDs should exist for Staging and Production. | no | |
| NEW_RELIC_KEY | API Key for New Relic. The New Relic Key is the same for Staging and Production.  | no | |
| TOUCHPOINTS_EMAIL_SENDER | email address when Touchpoints sends email. Account Confirmation, Password Reset, Submission Notification | yes | |
| TOUCHPOINTS_GTM_CONTAINER_ID   | GTM to deliver analytics for the deployed app/Product itself | no | | |

## Deploying the Touchpoints Application to Cloud.gov

Assuming you've setup the environment variables above.

Assuming `manifest.yml` is properly configured
Assuming you have `/tmp/goggle_service_account_ENV.json` in place for your respective ENV.
  * note: in `test` environment, the .json string is copied to CircleCI as `GOOGLE_CONFIG`
Assuming you have other ENVs set (see Section above)

* push to staging using `cf push touchpoints-staging`
* push to staging using `cf push touchpoints-demo`

---

## Additional Notes for Developers

Running Touchpoints requires a Google Service Account with access to Tag Manager, Drive, and Sheets API.
Be sure to add the Service Account email address to the Google Tag Manager Account User Management Panel.

#### General Developer Prerequisites

An onboarding Touchpoints Developer should have access to the following tools.

* GSA Email
* cloud.gov
* GitHub
* Google Drive
* Google Tag Manager
* AWS Simple Email Service
* Circle CI
* Snyk

### Configuring s3 for Touchpoints

Touchpoints stores Organization logo image files, and .pdfs of Service Maps for any given Touchpoint.

Here's how to configure cloud.gov S3 for Touchpoints:

1. Create a public S3 service in cloud.gov
1. Bind that s3 instance to your Touchpoints application application
1. Then look at the VCAP settings of that cloud.gov application instance, and set those configs in Touchpoints /config/initializers/carrierwave.rb
  * `aws_access_key_id`
  * `aws_secret_access_key`
  * `region`
  * `host`
  * `fog_directory` (the name of the S3 bucket)
