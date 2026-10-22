---
title: "Restrict future migrations to a lightweight, model-free format"
status: "accepted"
date: "2026-10-20"
decision_makers: ["Shelley Nason"]
category: "operations"
nist_controls: ["CM-3", "CM-6", "SA-8", "SA-11", "SA-15", "SI-17"]
impact_level: "moderate"
ato_relevance: "no"
risk_treatment: "mitigate"
---

# Restrict future migrations to a lightweight, model-free format

## Context and Problem Statement

Touchpoints recently started running deploy-time database migrations in Cloud Foundry as a
separate CI step (CircleCI) by staging a route-less, zero-instance "migrations"
app (for example `touchpoints-migrations` via `touchpoints-migrations.yml`) and
running `bundle exec rails db:migrate` as a one-off Cloud Foundry task (see
`./.circleci/migrate.sh`). Previously, it ran migrations as part of the start-up command during
the deployment of the Touchpoints app, which caused unpredictable mismatches from new code running
against an old schema during rolling deployments.

Lacking any immediate alternative, the migration app was deployed as yet another copy of the full Touchpoints Rails app.
That seemed excessively heavyweight for an app that just performs db migrations. We started to look for a lightweight
migration runner that did not need to boot the entire app. But without the app, you can't run migrations that reference 
application models. Historically, Touchpoints has used such migrations - 10 of the 48 migrations under `db/migrate/`
reference application models directly (e.g. `Form`, `Submission`). But should it use such migrations? They depend on
whatever validations, callbacks, scopes, or attribute logic those models carry **at the time the migration runs** — 
not necessarily the logic that existed when the migration was written. That is a correctness and historical-durability 
problem independent of migrator boot cost: a model-coupled migration can silently change behavior as the model evolves,
is harder to replay deterministically against a fresh database, and is harder to review in isolation.

Which brings us to the topic of this ADR, which requires two related decisions:
1. What migration format is allowed going forward (schema DSL / SQL vs.
   model-based Ruby).
2. What to do with the existing non-conforming migrations.

## Decision Drivers

- **Historical durability** — a migration should describe a database change
  as a fixed, replayable record, not depend on the current behavior of
  evolving application models (validations, callbacks, scopes, enums,
  attribute casting).
- **Reviewability and predictability** — schema DSL and direct SQL are easier
  to read, diff, and reason about than model-mediated Ruby logic.
- **Deploy coupling** — a schema/index migration should not be able to fail
  because of an unrelated web-app configuration concern (Login.gov, S3,
  SES, mailers, route helpers, encryption key setup).
- **Runtime weight** — deploy migrations should not pay full Rails boot cost
  when the work is limited to schema DDL or SQL data changes.

## Considered Options

### A. Migration format going forward

1. **Allow only schema DSL and direct SQL** (no application model references,
   no `Rails.*`, no app-coupled Ruby) for all new migrations.
2. **Allow model-based migrations to continue** as long as they pass under
   whichever runner is in use (status quo prior to this ADR).
3. **Allow schema DSL/SQL for schema changes, but require data backfills to
   run as a separate operational task** outside the migration framework
   entirely (e.g. a Rake task or one-off script invoked manually).

### B. Treatment of existing non-conforming migrations

1. **Leave as-is** — keep the model-coupled migrations as historical files;
   full-history replay continues to require full Rails.

2. **Delete everything before a chosen cutover version** — delete all
   pre-cutover migrations without a replacement baseline. Bootstrap new
   databases from `db/schema.rb` (`rails db:setup` or `rails db:schema:load`)
   and use `rails db:migrate` only for incremental upgrades.

## Decision Outcome

Chosen options: **A.1 — allow only schema DSL and direct SQL for new
migrations**, going forward, on both historical-durability and operational
grounds, independent of which runner executes them; and **B.2 — delete all
migrations dated on or before `20250211191435`** (the last migration before
A.1 took effect, and the most recent migration to reference an application
model). `db/schema.rb` is the canonical bootstrap artifact for new databases;
the 34 deleted migration files are not replaced with a new baseline migration.

### Rationale for A.1

Model-based migrations are undesirable for reasons beyond deploy boot cost.
They couple historical database changes to evolving application code, making
them less deterministic, harder to review, more fragile to replay, and more
likely to change behavior as validations, callbacks, scopes, enums, or
attribute logic evolve over time. This holds regardless of which migration
runner executes them, so the rule is adopted on its own merits rather than
purely as an implementation detail of a lightweight runner.

**On A.3:** banishing data backfills from migrations entirely was considered
but rejected as unnecessary — simple SQL backfills (e.g., `BackfillSpamFlag`
above) don't carry the model-coupling problem A.1 is meant to solve, and A.3
would add operational-task tooling the project doesn't otherwise need. Large
or locking backfills remain a reason to revisit this later.

### Rationale for B.2

B.2 was chosen because the project already bootstraps new databases from
`db/schema.rb` (`rails db:setup` in the developer guide and `db:schema:load`
in CI), and has prior precedent for deleting old migration files. A generated
baseline would duplicate `schema.rb` solely to support an empty-database
`db:migrate` path the project does not use. The deleted history remains
available in git.

### Positive Consequences

- A single, durable rule for future migrations: schema DSL and SQL only, no
  application model coupling — independent of runner choice.
- Reduces the risk of a migration's behavior silently changing as app models
  evolve.
- Keeps migrations reviewable without needing knowledge of current model
  internals.

### Negative Consequences

- A future migration that references app models or Rails initialization will
  fail under the deploy migrator unless caught in review/CI.
- Some data migrations that were historically convenient to write as Ruby
  inside a Rails migration will need a different execution path (a separate
  operational task) instead.
- Data migrations must explicitly enforce required data invariants. Direct
  SQL does not run application validations or callbacks, so migrations must
  encode necessary constraints, filters, defaults, and integrity checks in
  SQL/DDL, or use a separate operational task when application-aware behavior
  is required.
- The granular per-file historical record of the 34 squashed migrations
  (including exactly how and when each pre-cutover data value was
  backfilled) is no longer present in `db/migrate/`; it remains available
  only in git history for the deleted files.

### Compliance Consequences

- Supports **CM-3 / CM-6** by making deploy-time change execution more
  explicit and tightly scoped, and by giving future migrations a documented,
  enforceable format.
- Supports **SA-8 / SA-15** by recording an intentional engineering/operations
  boundary for schema changes and documenting the squash decision and its
  verification status rather than leaving them implicit.
- Supports **SA-11** by encouraging a migration contract (schema DSL/SQL only)
  that is easier to test in isolation.
- Supports **SI-17** by reducing avoidable failure modes caused by unrelated
  app boot dependencies or model-coupled behavior during a database change.
- No effect on the authorization boundary (`ato_relevance: no`).

## Allowed Migration Format

New migrations MUST be self-contained database changes expressed using only
the ActiveRecord migration DSL and/or direct SQL. They MUST NOT depend on
application models, application code, or Rails initialization, regardless of
which runner (lightweight or full Rails) ultimately executes them.

### Allowed in New Migrations

1. **Standard schema changes using ActiveRecord migration DSL** such as:
   `create_table`, `drop_table`, `add_column`, `remove_column`,
   `change_column`, `add_index`, `remove_index`, `add_foreign_key`, and
   `change_table`.
2. **Direct SQL executed inside the migration** using `execute`, including DDL,
   constraint changes, concurrent indexes, and SQL backfills.
3. **Data updates expressed as SQL against tables** rather than app models,
   loops over rows, or Ruby-side transformations.
4. **Small, self-contained Ruby only where necessary** for migration control
   flow, with the actual database change remaining schema DSL or SQL.

### Not Allowed in New Migrations

1. **Application model references** such as `Form.update_all`,
   `Submission.where`, `User.find_each`, or any constant from `app/`.
2. **Rails application objects or runtime services** such as `Rails.application`,
   `Rails.cache`, route helpers, mailers, jobs, uploaders, or middleware.
3. **Dependencies on environment config or initializers** such as S3,
   Login.gov, SES, host configuration, or other application boot concerns.
4. **Any migration whose correctness depends on full Rails boot, autoloading,
   or application runtime behavior**.

### Discouraged

1. **Temporary ActiveRecord model classes defined inside migrations**. These may
   sometimes work without full Rails boot, but they still couple the migration
   to model semantics more than necessary. Prefer direct SQL instead.
2. **Nontrivial Ruby data manipulation inside migrations**. Prefer a single SQL
   statement or a separate operational task over Ruby loops, batching logic, or
   transformation code embedded in the migration itself.

### Examples

Allowed:

```ruby
class AddArchivedAtToForms < ActiveRecord::Migration[8.1]
  def change
    add_column :forms, :archived_at, :datetime
    add_index :forms, :archived_at
  end
end
```

```ruby
class BackfillSpamFlag < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      UPDATE submissions
      SET spam = false
      WHERE spam IS NULL
    SQL
  end
end
```

Not allowed:

```ruby
class BackfillSpamFlag < ActiveRecord::Migration[8.1]
  def change
    Submission.update_all(spam: false)
  end
end
```

```ruby
class ClearCache < ActiveRecord::Migration[8.1]
  def change
    Rails.cache.clear
  end
end
```

## Guardrails and Follow-on Rules

1. **Use schema DSL for ordinary schema changes** — columns, tables, indexes,
   and foreign keys should generally use standard ActiveRecord migration DSL.
2. **Use direct SQL for data changes** — backfills, mass updates, and other data
   transformations should default to SQL rather than Ruby logic inside the
   migration.
3. **Avoid nontrivial Ruby in migrations** — if the change needs loops,
   batching, branching business logic, or application-aware transformation,
   that work likely belongs in a separate operational task.
4. **Separate schema from app-coupled data work** — if a backfill or data fix
   needs application code, run it via a separate operational task rather than
   the deploy migrator.
5. **Use schema-loading commands to bootstrap a new database** — use `rails
   db:setup` (the developer-guide path), `rails db:schema:load`, or `rails
   db:prepare`; do not use `rails db:migrate` alone against an empty database.
6. **Use `rails db:migrate` only for incremental upgrades** — it applies
   migrations introduced after the version already recorded by `schema.rb` or
   `schema_migrations`.

## Follow-up Work

- Consider adding CI or review-time checks that flag new migrations referencing
  application models or Rails constants, to enforce the "Allowed Migration
  Format" rule automatically.
