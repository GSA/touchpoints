_**Please note that this project is in very early development and is not guaranteed stable at this time.**_

# Touchpoints [WIP]

User-centered feedback platform for continuous improvement of systems, services, processes, and policy.

### High-level technical overview

* Rails app
* Runs on Cloud.gov
* Uses a PostgreSQL database
* Leverages Google Tag Manager API

### To start development

* run `git clone ...` on the repo
* copy `.env.sample` to `.env.development` and set your configs
* install Ruby, Postgres, Selenium (for specs) - on OSX, `brew install postgres selenium-standalone-server`
* run `bundle` to install Ruby dependencies
* run `rake db:create` to create the database
* run `rake db:reset` to wipe and load the database with seeds
* run `rails s -p 3000` to start the server
* run `rspec spec` to run specs/tests

Also required:

* get a Google Tag Manager Account ID (set it in `.env.development`)
* get a Google Dev Console Service Account with Access to the account above

### To deploy

* configure Cloud.gov stuff...
* copy `manifest.sample.yml` to `manifest.yml` and set your configs
* run `cf push`

For assistance, contact [Ryan Wold](mailto:ryan.wold@gsa.gov)
