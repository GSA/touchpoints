---
title: Widget output caching
description: Cache behavior and local verification for issue 2157.
status: draft
tier: 2
last_updated: 2026-11-09
---

# Widget output caching

To avoid rendering the same widget on every page load, `Form#touchpoints_js_string`
caches the complete JavaScript output in the existing Rails cache. No new service
or database migration is required. This work addresses
[issue #2157](https://github.com/GSA/touchpoints/issues/2157).

## Behavior

- The first request renders; subsequent requests reuse the output for up to one hour.
- Each form and locale has separate output. Entries are compressed by the cache store.
- Form, question, option, section and organization changes invalidate output.
  Submission-only changes to `last_response_created_at` and `updated_at` invalidate
  the cached model but retain widget output. Explicit touches still invalidate output.
  Section sorting validates all IDs against the current form and explicitly touches
  that form because its bulk updates skip callbacks.
- Invalidation rotates a per-form revision shared by releases and locales. A render
  that overlaps an edit can finish its current response, but cannot poison the new
  revision's cache. On a miss, the form is reloaded after capturing the revision.
- Application source, translations, configuration and relevant runtime settings
  contribute to a digest in the key. Production computes it once per process;
  development recomputes it to detect local file changes.
- CSRF-enabled forms and unsaved changes bypass the cache. Render failures are not cached.
- Activation counting and legacy URL lookup are unchanged. Hosted forms render their
  partial directly, bypassing the cache. Admin previews use the same public
  `/touchpoints/:id.js` endpoint as a live embed and do use the cache.
- Old revision output expires naturally. Revision markers are small, persistent cache
  entries; eviction creates a fresh UUID rather than reusing an old revision.

Bulk data changes outside these model callbacks must call
`FormCache.invalidate(form.short_uuid)` after committing. Code changes made through
normal deployments change the source digest; data-only maintenance still requires
explicit invalidation. Do not clear the entire shared Redis database.

### Failed invalidation

RedisCacheStore can return `nil` instead of raising when a revision write fails.
Invalidation checks the result, returns `false`, and logs the structured event
`widget_cache_invalidation_failed` with the form's short UUID. An intentionally
disabled cache (`NullStore`) does not report an invalidation failure.

This detects failed invalidation; it does not guarantee cache freshness during an
outage. The database change has already committed. If Redis recovers with the old
revision intact, old output may be served until its one-hour expiration. After
connectivity recovers, retry `FormCache.invalidate(form.short_uuid)` to rotate the
revision. Raising from `after_commit` would not roll back the saved change or
repair the cache.

### Source digest choice

The source digest works without an injected release/build identifier, and reuses
output across deployments whose hashed source and runtime settings are unchanged.
The patterns deliberately cover broad application directories rather than a
hand-maintained list of widget partials. A release identifier would simplify this
if deployment tooling supplied it consistently, at the cost of a cold widget cache
on every release. The digest also detects local development edits without requiring
a new build identifier.

Question moves through the admin controller are blocked by #2172. Model-level moves
still invalidate both forms, including when performed by maintenance code. Removing
the organization-name dependency is tracked separately in
[issue #2173](https://github.com/GSA/touchpoints/issues/2173).

## Local verification

Use the Ruby/Bundler versions pinned in `.ruby-version` and `Gemfile.lock`, with
PostgreSQL and Redis running and your normal local environment configured.
Ensure `DATABASE_URL`, if exported, points to a dedicated **test** database when
running specs: the suite uses DatabaseCleaner truncation.

```sh
RAILS_ENV=test bundle exec rails db:prepare
bundle exec rspec spec/models/form_cache_spec.rb spec/requests/widget_cache_spec.rb spec/controllers/admin/form_sections_controller_spec.rb spec/controllers/touchpoints_controller_spec.rb
bundle exec rubocop app/models/form_cache.rb app/models/form.rb app/models/organization.rb app/models/question.rb app/models/question_option.rb app/models/form_section.rb app/controllers/admin/form_sections_controller.rb app/controllers/benchmark_controller.rb spec/models/form_cache_spec.rb spec/requests/widget_cache_spec.rb
```

The request specs use real commits and an isolated MemoryStore to test invalidation,
including repeated requests, legacy IDs, counting, edits, deletes, section sorting,
locales and CSRF bypasses. They do not require a browser. To verify widget interaction,
stop any app server using port 3000, then run:

```sh
bundle exec rspec spec/features/touchpoints_spec.rb
```

For a manual run, `REDIS_URL` enables the Redis cache in development unless
`tmp/caching-dev.txt` exists (which selects MemoryStore). Check the selected store:

```sh
bundle exec rails runner 'puts Rails.cache.class.name'
bundle exec rails db:prepare
bundle exec rails server
```

If it reports `NullStore`, run `bundle exec rails dev:cache` once and restart the
server. That command is a toggle, not an idempotent enable command.

Open `/touchpoints/<short_uuid>.js` twice, then edit the form and reload. Check that
deleted options disappear and that `?locale=es` stays separate from English. Use
the form's Delivery preview to check the button, modal, validation and submission.

## Performance verification

Development request timings include reload checks and source hashing and are not
representative of production. Use a production-like test instance, Redis and local
test data to measure the issue's 150 requests/second target. Warm the widget cache
first, then measure sustained **origin** requests to `/touchpoints/<short_uuid>.js`,
including response status, latency and error rate. The activation counter still
performs a database update per request. Do not claim the throughput target from a
render microbenchmark or browser-cache hits.

### Isolating development source-hashing overhead

For a controlled local comparison, set `WIDGET_CACHE_MEMOIZE_DIGEST=true` in
`.env.development` and recreate the app container:

```sh
docker compose up -d --force-recreate webapp
```

Only the exact value `true` enables this option. The default remains recomputing
the digest in development; outside development it is already memoized. With this
option enabled, restart the app after source, translation or configuration edits
to ensure the digest reflects them. Rails code reloads may also reset memoization;
avoid editing source files during the comparison. Database edits still invalidate
widget output normally.

Warm the same widget endpoint, then repeat the same request count and concurrency.
This isolates repeated source hashing, but other development overhead remains, so
the result is still not a production capacity measurement. After testing, remove
the flag or set it to `false`, then recreate the app container again.

This AI-assisted change requires human review and passing local/CI checks before deployment.
