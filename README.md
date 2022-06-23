![Touchpoints Logo](https://github.com/GSA/touchpoints/blob/main/app/assets/images/touchpoints-logo-@2x.png?raw=true)

## Overview

Touchpoints enables government agencies
to solicit and process user feedback to
support continuous improvement of public service delivery.

An example Touchpoints form that includes every input element
is available in this
[Kitchen Sink](https://touchpoints.app.cloud.gov/touchpoints/34d93e4e/submit)
example.

Touchpoints is a web application
that makes it easy to deploy
compliant feedback forms quickly.
Touchpoints provides features specific to the
[domain](https://en.wikipedia.org/wiki/Domain-driven_design/) of
[Customer Experience](https://www.performance.gov/cx/)
in the US Federal Government.

GSA's Federal Acquisition Service (FAS) is developing Touchpoints in-house by the
[Feedback Analytics Team](mailto:feedback-analytics@gsa.gov),
within the Technology Transformation Services'
[Data Portfolio](https://www.gsa.gov/about-us/organization/federal-acquisition-service/technology-transformation-services/tts-solutions#data).

Touchpoints is online at <https://touchpoints.digital.gov/>.

A current Demo version is online at <https://touchpoints-demo.app.cloud.gov/index/>,
and government customers are [encouraged](https://github.com/GSA/touchpoints/wiki/Touchpoints-Demo-Environment/) to sign up and try it out.

## Documentation

See the [Touchpoints wiki](https://github.com/gsa/touchpoints/wiki) for more information.

## Team Process

The Touchpoints team tracks work in a [backlog](https://en.wikipedia.org/wiki/Kanban) board.

Issues and ideas are also noted in GitHub [Issues](https://github.com/gsa/touchpoints/issues).

## Docker development

Setup

1. install Docker
2. clone repo
3. copy .env.sample .env and update vars

To build a development environment

1. docker-compose build
2. docker-compose run webapp rails db:create
3. docker-compose run webapp rails db:setup
4. docker-compose up
5. Navigate to http://lvh.me:3002/admin

To start/stop after building
1. docker-compose up
2. docker-compose down

To run tests (TBD -- this currently does not work with selenium web driver)
1. docker-compose run webapp rspec

## Code linting
- Run the script `./rubocop_autocorrect.sh` to fix standardize layout, style, and code using Rubocop
- copy the file ./pre-commit to your .git/hooks/ folder within the project to ensure changed files adhere to project standards, prior to commit.
- to get a commit through without running that pre-commit hook, use the --no-verify option

## License

See [LICENSE](LICENSE.md)
