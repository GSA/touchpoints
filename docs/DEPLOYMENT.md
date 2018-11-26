# Deployment

Touchoints is currently deployed in 2 environments:

1. [Staging](https://touchpoints-staging.app.cloud.gov)
1. [Production](https://touchpoints.app.cloud.gov)

These environments are managed via cloud.gov,
and are currently configured to run on Cloud Foundry, but can run elsewhere with relatively little modification.

### To Deploy

Deploying Touchpoints requires pushing a local version of Touchpoints code (the repo) to an instance in Cloud Foundry using the `cf push` command.

`cf push` referencs a local `manifest.yml` that declares one or more applications.
Thus, having a "properly configured" manifest.yml file is a prerequisite/dependency/requirement.

To deploy a specific instance `cf push touchpoints-staging` or `cf push touchpoints`, respectively.
