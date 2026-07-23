# Measuring the Impact of Cloudflare Turnstile on a Form

This guide describes how to decide whether enabling Cloudflare Turnstile on a
Touchpoints form is actually reducing spam, and what to measure before and
after turning it on.

## How Turnstile is wired in this app

- Turnstile is toggled per form via the `enable_turnstile` boolean
  (`app/models/form.rb`, `app/views/admin/forms/_admin_options.html.erb`).
- On submission, if the form has Turnstile enabled, the server verifies the
  `cf-turnstile-response` token against Cloudflare's siteverify endpoint
  (`app/controllers/submissions_controller.rb`, `verify_turnstile`).
- On success, the submission is stamped
  `spam_prevention_mechanism = "turnstile"`.
- On failure, an error is added and **the submission is not saved**.

Because failed submissions are discarded and not logged or counted, the
database records what got through, not what was blocked. Keep this in mind
when interpreting the numbers below.

## The one durable signal the app already stores

`submissions.spam_prevention_mechanism`:

- Set to `"turnstile"` only when verification passes.
- Defaults to `""` for everything else.

Quick query for how many submissions were Turnstile-verified after enabling:

```sql
SELECT spam_prevention_mechanism, COUNT(*)
FROM submissions
WHERE form_id = <id> AND created_at >= '<enable_date>'
GROUP BY 1;
```

If Turnstile is enabled but few rows are stamped `turnstile`, that suggests a
configuration problem (e.g., missing `TURNSTILE_SITE_KEY` /
`TURNSTILE_SECRET_KEY`), not an absence of bots.

## Metrics to capture BEFORE enabling (baseline)

Use a stable window of 2-4 weeks on the same form:

1. **Total submission volume per day** — the denominator for everything else.
2. **Spam/junk rate** — however you currently identify spam (manual triage,
   keyword patterns, obvious bot content, duplicate bursts). This is the number
   you are trying to move.
3. **Completion / abandonment** — any funnel data you have (widget opens vs.
   submits). Turnstile adds friction, so watch for legitimate drop-off.
4. **Duplicate / burst patterns** — submissions from the same IP or in rapid
   succession. IP is only stored if `organization.enable_ip_address?` is set.

## Metrics to capture AFTER enabling

1. **Spam rate** vs. baseline — the primary success metric.
2. **Share of submissions marked `turnstile`** — see the query above.
3. **Total legitimate volume** — did real submissions drop? A large fall may
   indicate friction/abandonment rather than blocked bots.
4. **Blocked (failed) submissions** — not recorded in the app today; see gap
   below.

## Known measurement gap: blocked submissions

The most valuable metric — how many submissions Turnstile actually blocked — is
not recorded anywhere. When verification fails, the submission is discarded with
no counter, no log line, and no persisted row. Without it you cannot distinguish
"Turnstile blocked many bots" from "Turnstile did nothing."

Ways to close the gap:

- **Cloudflare dashboard (no code):** Turnstile analytics on Cloudflare's side
  show challenge / solve / fail counts.
- **Lightweight logging (low risk):** add a log line in the verification-failure
  branch counting failures with the form id and IP.
- **Persisted attempt counter (schema change):** durable before/after data in
  the app itself.

## Interpreting the results

| Observation | Likely interpretation |
|---|---|
| Spam down, legit volume steady | Turnstile is working — keep it |
| Spam down, legit volume also down noticeably | Friction may deter real users — investigate abandonment |
| Spam unchanged, few `turnstile`-stamped rows | Misconfiguration (keys/env) — verify before concluding it fails |
| Spam unchanged, many `turnstile`-stamped rows | Spam was not bot-driven — Turnstile is the wrong tool |

## Controlling for confounders

- Compare before/after on the **same form** over comparable-length windows.
- Watch for external changes (a shared link, seasonal traffic) that move volume
  independently of Turnstile.
