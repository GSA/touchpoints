---
title: "Use a task-only Rails migration app for deploy-time migrations"
status: "accepted"
date: "2026-10-22"
decision_makers: ["Shelley Nason"]
category: "operations"
nist_controls: ["CM-3", "CM-6", "SA-8", "SA-11", "SA-15", "SI-17"]
impact_level: "moderate"
ato_relevance: "no"
risk_treatment: "mitigate"
---

# Use a task-only Rails migration app for deploy-time migrations

## Context and Problem Statement

Touchpoints previously ran migrations as part of app startup with a command like:

```bash
bundle exec rake cf:on_first_instance db:migrate && bundle exec rails s -b 0.0.0.0 -p $PORT -e $RAILS_ENV
```

That was a problematic deploy-time pattern. During a rolling deploy, app instances can be
started, stopped, and replaced while old and new droplets coexist. Coupling
migration execution to web startup made it possible for application code and
database schema to move out of order, and made migration success depend on one
web instance reaching the startup command first.

The goal is to complete database migrations successfully before updating worker
or web application code.

## Considered Options

1. **Run migrations from web app startup** — keep the old startup command and let
   the first web instance run migrations before starting Rails.
2. **Run migrations from CI against the database directly** — run Rails or a Ruby
   migration runner from CircleCI rather than inside Cloud Foundry.
3. **Stage a task-only Rails migration app** — push the same Rails code as a
   Cloud Foundry task-only app, run `bundle exec rails db:migrate`, and only then
   deploy worker and web apps.
4. **Stage a non-Rails migration app** — push a smaller Ruby app containing only
   ActiveRecord, PostgreSQL, a migration runner, and `db/migrate`.

## Decision Outcome

Chosen option: **Option 3 — stage a task-only Rails migration app**.

CircleCI stages a dedicated migration app with `cf push --task`, then runs:

```bash
bundle exec rails db:migrate
```

Worker and web rollout proceed only after the migration task succeeds.

Running migrations directly from CircleCI was rejected because it would require
CI to have direct database network access and production database credentials,
instead of running inside the existing Cloud Foundry app/service-binding
boundary.

## Why Not The Old Startup Command

The old startup-command approach was rejected because it mixed two separate
concerns: changing the database schema and starting web traffic handlers. It also
made deploy behavior harder to reason about under rolling deploys, because the
migration ran as a side effect of starting one app instance rather than as an
explicit deployment phase.

For this deployment model, migrations should run before new code and leave the
schema compatible with the currently deployed code. In other words, old code must
continue to work with the new schema while the rollout is in progress; new code
can assume the migration has already succeeded before it starts.

By making migrations their own CI step, deploy order is explicit:

1. stage the migration app
2. run migrations
3. deploy workers
4. deploy web

## Notes On The Non-Rails Migrator Attempt

A smaller non-Rails migration app was considered and partially prototyped. The
idea was attractive because future migrations are expected to be model-free and
could theoretically run with only ActiveRecord and PostgreSQL.

In practice, packaging the non-Rails app for the Cloud Foundry Ruby buildpack was
more complicated than expected:

- A package containing the root Rails `Gemfile` caused the buildpack to detect a
  Rails app and run Rails-specific staging steps, even when Bundler was limited
  to a small migration group.
- A tiny generated `Gemfile` avoided Rails detection, but the buildpack required
  a `Gemfile.lock`.
- Generating and carrying a separate temporary lockfile added complexity and made
  the deployment path harder to understand.
- The non-Rails app avoided Rails boot, but introduced custom migration runner
  and packaging behavior in a critical deploy path.

For now, standard Rails migration behavior is worth the heavier staging cost.
The non-Rails approach can be reconsidered later if deploy duration becomes more
important than keeping the migration path simple.

## Consequences

- Migrations run before new worker/web code is deployed.
- Migration execution uses the standard Rails migration task.
- The migration app must have enough bindings and environment configuration to
  boot Rails, including database, Redis, S3, and required non-secret env vars.
- The migration app still stages the full Rails application, so this does not
  solve migration staging time by itself.
- Future CUPS work should reduce config drift between web, worker, and migration
  apps.

## Links

- [ADR 0002: Restrict future migrations to a lightweight, model-free format](0002-restrict-future-migrations-to-lightweight-format.md)
- `.circleci/migrate.sh`
- `touchpoints-migrations.yml`
- `touchpoints-staging-migrations.yml`
- `touchpoints-demo-migrations.yml`
