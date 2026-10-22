---
title: "Use a standalone ActiveRecord migrator for deploy-time migrations"
status: "accepted"
date: "2026-10-22"
decision_makers: ["Shelley Nason"]
category: "operations"
nist_controls: ["CM-3", "CM-6", "SA-8", "SA-11", "SA-15", "SI-17"]
impact_level: "moderate"
ato_relevance: "no"
risk_treatment: "mitigate"
---

# Use a standalone ActiveRecord migrator for deploy-time migrations

## Context and Problem Statement

Touchpoints runs deploy-time database migrations in CircleCI by pushing a
route-less, zero-instance Cloud Foundry migration app and running a one-off task
before the worker and web rollouts. That migration app previously staged the
full Rails application and ran `bundle exec rails db:migrate`.

That approach has two problems:

1. It slows deployments by uploading, staging, and bundling the full Rails app
   for a task that only needs ActiveRecord migration APIs and PostgreSQL.
2. It requires migration deploys to satisfy environment-variable requirements
   that have nothing to do with migrations, because Rails boot loads unrelated
   application configuration such as auth, mail, storage, assets, and web
   middleware.

## Decision Drivers

- Speed up deploy-time migrations by pushing and staging a smaller Cloud Foundry
  app.
- Remove unrelated Rails application environment requirements from the migration
  execution path.
- Keep one permanent dependency source of truth by using the root `Gemfile` and
  `Gemfile.lock`.
- Continue relying on ADR 0002's rule that new migrations are model-free and
  standalone-safe.

## Considered Options

1. **Keep staging the full Rails app and run `rails db:migrate`** — preserves the
   previous behavior, but keeps the deploy-time cost and unrelated env-var
   coupling.
2. **Use the `standalone_migrations` gem** — provides a small migrator wrapper,
   but adds another migration-specific dependency.
3. **Use a custom standalone ActiveRecord migrator** — package the root
   dependency files, a small Ruby script, and `db/migrate`, then run
   ActiveRecord's migration context directly.
4. **Create a separate migrator Gemfile** — keeps the package very small, but
   introduces a second permanent dependency manifest in the repository.

## Decision Outcome

Chosen option: **Option 3 — use a custom standalone ActiveRecord migrator**.

The deploy job builds a temporary `tmp/cf-migrator` package containing:

- root `Gemfile`
- root `Gemfile.lock`
- `bin/standalone-migrate`
- copied `db/migrate` files

The package-local Bundler config uses `BUNDLE_ONLY: "migrator"`, so the Cloud
Foundry Ruby buildpack installs only the migrator dependency group. CircleCI then
pushes that package and runs:

```bash
bundle exec ruby bin/standalone-migrate
```

The script connects with `DATABASE_URL`, sets `RAILS_ENV` when absent so
ActiveRecord migration metadata has an environment value, validates `VERSION`,
and invokes `ActiveRecord::MigrationContext` against the packaged migrations.

### Positive Consequences

- Migration deploys should be faster because Cloud Foundry receives and stages a
  smaller app with a smaller Bundler dependency set.
- Migration deploys no longer need unrelated Rails app env vars solely to boot
  the application.
- The repo keeps one permanent `Gemfile`/`Gemfile.lock`.
- The implementation aligns with ADR 0002's model-free migration rule.

### Negative Consequences

- Deploy-time migrations no longer execute the exact `rails db:migrate` task;
  they use ActiveRecord's migration context directly for a single database.
- The runner assumes `DATABASE_URL` is complete and correct in cloud.gov.
- Future migrations that depend on Rails boot, application models, initializers,
  or app constants will fail under the deploy migrator.
- Local use can differ from Rails if a developer's `DATABASE_URL` omits the
  database name; this script is intended primarily for the cloud.gov deploy path.

### Compliance Consequences

- Supports **CM-3 / CM-6** by making the deploy migration mechanism explicit and
  scoped to the minimum files required for migration execution.
- Supports **SA-8 / SA-15** by documenting the boundary between database
  migrations and full Rails application boot.
- Supports **SA-11 / SI-17** by adding test coverage for the custom runner and
  reducing failure modes caused by unrelated app configuration.
- Does not change the system authorization boundary (`ato_relevance: no`).

## Operational Rules

1. New migrations MUST continue to follow ADR 0002: schema DSL and direct SQL
   only, no application model or Rails runtime dependencies.
2. Generated files under `tmp/cf-migrator` MUST NOT be committed.
3. The root `Gemfile` MUST keep the `migrator` dependency group aligned with the
   Rails/ActiveRecord version used by the application.
4. The migration task MUST continue to run after acquiring the deployment lock and
   before worker/web rollout.

## Rollback

Restore `.circleci/migrate.sh` to push the full Rails workspace and run
`bundle exec rails db:migrate`, and remove the standalone migrator package step.

## Links

- [ADR 0002: Restrict future migrations to a lightweight, model-free format](0002-restrict-future-migrations-to-lightweight-format.md)
- `.circleci/migrate.sh`
- `.circleci/build-migrator-package.sh`
- `bin/standalone-migrate`
