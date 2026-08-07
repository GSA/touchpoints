---
title: "Introduce a service object layer (app/services)"
status: "accepted"
date: "2026-07-31"
decision_makers: ["Shelley Nason"]
category: "code-architecture"
nist_controls: ["SI-10", "SA-8", "SA-11", "SA-15"]
impact_level: "moderate"
ato_relevance: "no"
risk_treatment: "n/a"
---

# Introduce a service object layer (app/services)

## Context and Problem Statement

Touchpoints is conventional Rails MVC with fat models and orchestration-heavy
controllers, and no service/domain layer. To take form submission as an example,
logic currently lives inside model methods (notably the
~120-line `Submission#validate_answers`) and controller methods (the
`SubmissionsController` spam pipeline). Logic within the controller, 
in particular, is hard to test in isolation and reuse. We'd like to add to
the spam-detection logic but first we need to extract it from the controller layer.
Eventually, we'd also like to move some validation logic out of the models, so
that Active Record models focus on persistence, not on per-form input rules.

## Decision Drivers

- **SI-10 (Input Validation)** — input validation should be explicit,
  cohesive, and independently testable.
- Reduce the size/complexity of god objects (`Form`, `Submission`) and fat
  controllers.
- Establish a conventional, discoverable location so future contributors follow
  the same pattern.
- Prefer the smallest change that holds (Laziness Ladder): use plain Ruby
  objects rather than adding a new dependency.

## Considered Options

1. **Add a service-object layer (`app/services`)** — plain Ruby operation
   objects with a `call` method that own the "what happens on submit" workflow
   and spam detection, delegating persistence to models.
2. **Keep validation in models / controllers (status quo)** — continue placing
   context-specific validation in model methods and controller privates.
3. **Introduce `app/forms/` form objects (ActiveModel::Model POROs)** — a
   top-level autoloaded directory of `*Form` classes that own input validation
   and integrate with Rails view/error conventions.
4. **Adopt a third-party gem** (e.g., `reform`, `dry-validation`) — dedicated
   form/validation library.

## Decision Outcome

Chosen option: **Option 1 — introduce `app/services/` service objects (plain
Ruby objects exposing `#call`)**, because it gives submission-handling and
spam-detection logic a cohesive, independently testable home without a new
dependency, and directly reduces model/controller bloat. Service objects are a
widely recognized Rails convention (a single `#call` entry point, interoperable
with `Proc#call`), which keeps the pattern discoverable for future
contributors.

Form objects (Option 3) were considered but not adopted: the immediate need is
to extract *orchestration and spam detection* (an operation/workflow) rather
than to model context-specific input validation bound to Rails form/error
conventions. A service layer is the better fit for that operation-shaped work.
Introducing service objects does not preclude adding form objects later if
context-specific input validation grows enough to warrant them.

### Positive Consequences

- Submission-handling and spam-detection logic is isolated, unit-testable, and
  reusable.
- Controllers can focus on receiving requests and generating responses, delegating complicated domain logic to more testable POROs.
- No new runtime dependency (plain Ruby objects).
- Standard, discoverable location (`app/services/`, specs in `spec/services/`).
- Spam detection is decomposed into small, individually testable check objects
  (`app/services/spam_checks/`) sharing a common duck-typed interface
  (`#call -> SpamChecks::Base::Result`), orchestrated by `SpamChecker#call`
  which returns a verdict (`:reject` / `:flag` / `nil`) for the controller to
  apply — replacing the controller's inline spam pipeline.

### Negative Consequences

- Introduces a new layer/pattern the codebase does not yet have; requires
  contributor familiarity and consistency.
- Adds a small object hierarchy for spam checks; over-decomposition is a risk if
  future checks are trivial (keep the frozen `DEFAULT_SPAM_CHECKS` registry
  simple rather than adding auto-discovery machinery).

### Compliance Consequences

- Supports **SI-10** by making spam-related input validation explicit and testable.
- Supports **SA-8 / SA-15** (security engineering / documented development
  process) via a clear layering decision recorded here.
- No effect on the authorization boundary (`ato_relevance: no`).
- Future migration of existing `Submission#validate_answers` logic should be covered by
  regression tests before removal from the model (`SA-11`).
