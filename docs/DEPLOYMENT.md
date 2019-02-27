# Deployment

Touchpoints is currently deployed in 2 environments:

1. [Staging](https://touchpoints-staging.app.cloud.gov)
1. [Production](https://touchpoints.app.cloud.gov)

These environments are managed via cloud.gov,
and are currently configured to run on Cloud Foundry, but can run elsewhere with relatively little modification.

### Technical details on how to Deploy Touchpoints

Deploying Touchpoints requires pushing a local version of Touchpoints code (the repo) to an instance in Cloud Foundry using the `cf push` command.

`cf push` references a local `manifest.yml` that declares one or more applications.
Thus, having a "properly configured" manifest.yml file is a prerequisite/dependency/requirement.

To deploy a specific instance `cf push touchpoints-staging` or `cf push touchpoints`, respectively.

### Team conventions around Deployment

* Code lives in `master`
* Devs work in feature-branches
* feature branches are pushed to https://touchpoints-123.app.cloud.gov (each Dev has their own Dev environment)
* feature-branches are submitted as Pull Requests and reviewed in GitHub
  * feature-branch is merged to master via the Pull Request
* green master builds get deployed to [Staging](https://touchpoints-staging.app.cloud.gov) automatically via CircleCI
  * Product Owner accepts/rejects Stories
* green master builds can be deployed to [Production](https://touchpoints-staging.app.cloud.gov) manually, coordinating with [Ryan Wold](mailto:ryan.wold@gsa.gov)
  * releases are tagged using `git tag 0.0.1`
