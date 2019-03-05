# What is our testing strategy?

## What tools do we use?

The following describes the state of automated testing for the Touchpoints product. Automated testing is used to ensure the highest level of software quality for the lowest cost.

Touchpoints is a Ruby/Rails application that uses RSpec as its testing framework.

With RSpec, software developers write test specifications that are designed to be executed on a regular basis. In RSpec, a "spec" is the same as a "test".

### RSpec tests include:
* Integration Tests - these tests cover the behavior of the whole system, as an end-user would experience it. These test open web browsers (Chrome) and click around like a user would. These are the "outer-most" tests.
* Unit Tests - these tests cover the behavior of objects and functions. For objects, individual instances are tested; the inputs, outputs, and various states the objects can have. Functions, by design don't carry as much object-oriented state as objects.

In Rails, unit tests exist for both Model objects and Controller objects.

In Rails, API tests can be tested using Controller specs (that operate against Ruby) or a Request specs (that operate against the http Ruby generates)

### For Frontend

Frontend is covered by Integration Specs. Integration Specs use Capybara and can perform nearly any action a user can perform.

### For Styles

We are not testing styles specifically at this time.
Tools like percy.io are available to show diffs and such.
Integration specs are relied upon to ensure the application functions, but does not ensure pixel-level stylistic perfection.

### For Documentation

Ruby syntax offers the ability to inline code that will be generated as help files. Currently, no documentation is being created, by we can consider using Swagger to document API when it is developed.
