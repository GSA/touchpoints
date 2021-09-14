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

## License

See [LICENSE](LICENSE.md)

## Docker development

Setup

1. install Docker
2. clone repo
3. copy env.docker-development .env and update vars

To build a development environment

1. docker-compose build
2. docker-compose up
3. docker-compose run webapp rake db:create
4. docker-compose run webapp rake db:migrate
5. docker-compose run webapp rake db:seed
6. docker-compose down
7. docker-compose up
8. Navigate to http://lvh.me:3003/admin

To start/stop after building
1. docker-compose up
2. docker-compose down

To run tests

With headless Chrome inside web container:
1.docker-compose exec webapp rspec

With GUI Chrome browser inside chrome container:
1. open vnc://localhost:5900 # To open screen sharing window. Input "secret" if asked for password.
2. docker-compose exec -e LAUNCH_BROWSER=true webapp rspec

Outside of the container  ( this is currently the only method that will pass all test cases )
1. update config/database.yml and set the test_db host to localhost
2. rspec

Notes:
+  Application is accessable at lvm.me port 3002
+  Postgres db container is accessible at localhost port 5432 ( stop your local postgres service, if running )



