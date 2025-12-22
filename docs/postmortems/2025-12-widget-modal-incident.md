# Post-Mortem: Touchpoints Widget Modal Button Not Working

**Date:** December 22, 2025  
**Author:** Riley Seaburg  
**Incident Duration:** ~December 18-22, 2025 (4 days)  
**Severity:** High - User-facing feature broken  
**Status:** Resolved

---

## Executive Summary

The Touchpoints feedback widget stopped functioning correctly on external sites using the "modal" delivery method. Users clicking the floating feedback button saw no response - the modal dialog did not open. Instead, in some cases, the form rendered inline at the bottom of the page. This issue affected multiple government websites including ncei.noaa.gov and touchpoints.digital.gov.

**Root Cause:** The Rust widget renderer (introduced for performance optimization) was missing the USWDS Modal initialization code for the `#fba-button` element, which is required for the modal to respond to click events.

---

## Timeline

### Background: Rust Widget Renderer Introduction

| Date | Event |
|------|-------|
| **Oct 29, 2025** | Initial Rust-based widget renderer added for performance optimization (12x improvement) |
| **Nov 4, 2025** | Rust widget renderer deployed with HTML body generation |
| **Nov 20-25, 2025** | Multiple fixes for Rust widget renderer (null booleans, path detection, library loading) |
| **Dec 1, 2025** | Production release with Rust widget renderer |

### Incident Timeline

| Date/Time | Event |
|-----------|-------|
| **Dec 15, 2025** | Release: WidgetRenderer load fix (#1914) deployed to production |
| **Dec 18, 2025** | Multiple deployment fixes for CF timeout, Sidekiq health checks, and widget CSS |
| **Dec 18, 2025** | Fix: Add CSS support to Rust widget renderer to fix modal positioning |
| **Dec 18, 2025** | Fix: Use fba-usa-modal class for USWDS Modal compatibility |
| **Dec 19, 2025** | Fix: custom-button-modal USWDS initialization added (partial fix) |
| **Dec 19, 2025 12:24 PM** | **Zendesk Ticket #37620 received** - Jimmy Baker (NOAA) reports widget showing form inline instead of modal toast |
| **Dec 19, 2025** | Multiple attempts to force Rust rebuild (version bumps, cargo clean, cache invalidation) |
| **Dec 22, 2025** | Root cause identified: Missing `#fba-button` initialization in Rust renderer |
| **Dec 22, 2025** | PR #1924 merged: Fix Rust widget renderer modal button initialization |
| **Dec 22, 2025** | PR #1925 created: Release to production |
| **Dec 22, 2025** | PR #1926 merged: Address additional PR feedback (element_selector escaping, code cleanup) |

---

## Root Cause Analysis

### The Problem

The Rust widget renderer (`ext/widget_renderer/src/template_renderer.rs`) generates JavaScript that initializes USWDS components for the feedback form. The `render_uswds_initialization()` function was missing critical code to initialize the USWDS Modal on the feedback button.

### ERB Template (Working - `_fba.js.erb` lines 858-875)

```javascript
// Ensure the button is also initialized if it exists
const fbaButton = document.querySelector('#fba-button');
if (fbaButton) {
    if (fbaUswds.Modal) {
        fbaUswds.Modal.on(fbaButton);
        fbaButton.classList.add('fba-initialized');
    } else {
        console.error("Touchpoints Error: fbaUswds.Modal is not defined");
    }
}
```

### Rust Renderer (Broken - missing this code entirely)

The Rust renderer only initialized:
- `fbaUswds.Modal.on(fbaModalElement)` - the modal container
- `fbaUswds.ComboBox.on(fbaFormElement)` - combo boxes
- `fbaUswds.DatePicker.on(fbaFormElement)` - date pickers

**Missing:** `fbaUswds.Modal.on(fbaButton)` - the button that opens the modal

### Why This Matters

The USWDS Modal component uses `data-open-modal` attributes on buttons to trigger modal opening. The `Modal.on(element)` call sets up event listeners on elements with this attribute. Without calling `Modal.on()` on the button, the button's click event was never connected to the modal opening behavior.

### Contributing Factors

1. **Incomplete port from ERB to Rust:** When the Rust widget renderer was created, the button initialization logic was not included
2. **No integration tests for widget behavior:** Unit tests focused on rendering output, not actual browser behavior
3. **Complexity of USWDS initialization:** The multi-step initialization process made it easy to miss one component
4. **Dec 18 fixes created false confidence:** The `custom-button-modal` fix on Dec 19 addressed a similar but different issue, masking the core problem

---

## Impact

### Affected Systems
- All Touchpoints forms using `delivery_method: 'modal'` rendered via the Rust widget renderer
- External government websites embedding Touchpoints feedback widgets

### User Impact
- Users could not submit feedback via modal widgets
- Floating "Feedback" button appeared but did not respond to clicks
- Some users saw forms render inline at page bottom (degraded experience)

### Known Affected Sites
- touchpoints.digital.gov
- ncei.noaa.gov (NOAA)
- Potentially other government sites using Touchpoints modal widgets

### Duration
- Approximately 4 days (Dec 18-22, 2025)
- Forms using ERB fallback or `inline` delivery method were unaffected

---

## Resolution

### Immediate Fix (PR #1924)

Added the missing button initialization code to the Rust renderer:

```rust
// Ensure the modal button is also initialized if it exists (for 'modal' delivery method)
const fbaButton = document.querySelector('#fba-button');
if (fbaButton) {{
    if (fbaUswds.Modal) {{
        fbaUswds.Modal.on(fbaButton);
        fbaButton.classList.add('fba-initialized');
    }} else {{
        console.error("Touchpoints Error: fbaUswds.Modal is not defined");
    }}
}}
```

### Additional Fixes (PR #1926)

1. **Fixed `modal_class` prefix bug:** Now respects `load_css` setting
   - `load_css=true`: uses `fba-usa-modal` prefix
   - `load_css=false`: uses `usa-modal` (no prefix)

2. **Added CSS backtick escaping:** Prevents JavaScript syntax errors when CSS contains backticks

3. **Fixed element_selector empty string handling:** Proper null/empty check for custom button selectors

4. **Removed unnecessary `cargo clean`:** Improves build performance

5. **Extracted mock request helper:** Reduces code duplication in form.rb

6. **Removed expired certificate file:** Security cleanup

---

## Lessons Learned

### What Went Well
- Quick identification of root cause once the ticket was received
- Comprehensive fix that addressed multiple related issues
- Good collaboration between team members

### What Went Wrong
1. **Incomplete feature parity testing:** The Rust renderer was not tested against all delivery methods
2. **No browser-based integration tests:** Would have caught the modal not opening
3. **Silent failure:** The widget appeared to load but just didn't work - no visible errors to users
4. **4-day detection lag:** Issue existed for several days before user report

### Where We Got Lucky
- User reported the issue promptly
- ERB fallback existed (though not automatically triggered in this case)
- The fix was straightforward once identified

---

## Action Items

### Immediate (This Sprint)

| Item | Owner | Status |
|------|-------|--------|
| Deploy fix to production (PR #1925) | Riley | In Progress |
| Verify widget works on touchpoints.digital.gov | Riley | Pending |
| Respond to Zendesk ticket #37620 | Riley | Pending |

### Short-term (Next 2 Weeks)

| Item | Owner | Status |
|------|-------|--------|
| Add browser-based integration tests for widget modal behavior | TBD | Not Started |
| Add automated smoke test that verifies modal opens on click | TBD | Not Started |
| Document Rust renderer feature parity requirements | TBD | Not Started |

### Long-term (Next Quarter)

| Item | Owner | Status |
|------|-------|--------|
| Implement automatic fallback to ERB if Rust-rendered widget fails to initialize | TBD | Not Started |
| Add client-side error reporting for widget initialization failures | TBD | Not Started |
| Create widget health monitoring dashboard | TBD | Not Started |

---

## Deployment History (Dec 18-22)

The following commits were deployed to production during the incident period:

```
Dec 22: Fix Rust widget renderer modal button initialization (#1924)
Dec 22: Address PR feedback (element_selector, cargo clean, form.rb refactor)
Dec 19: Fix custom-button-modal USWDS initialization
Dec 19: Multiple cargo/version bumps to force rebuild
Dec 18: Fix CSS support, fba-usa-modal class
Dec 18: Deployment timeout and Sidekiq fixes
Dec 18: Set prod disk quota to 2G
Dec 15: WidgetRenderer load fix (#1914)
```

---

## Cloud Foundry Events Summary

**Production (touchpoints):**
- Last successful deployment: Dec 19, 2025 22:06 UTC
- 18 web instances running
- No crash events during incident period

**Staging (touchpoints-staging):**
- 6 crash events on Dec 22 (unrelated - test environment)

---

## References

- Zendesk Ticket: #37620
- PR #1924: Fix Rust widget renderer modal button initialization
- PR #1925: Release to production
- PR #1926: Address PR feedback
- ERB Template: `app/views/components/widget/_fba.js.erb`
- Rust Renderer: `ext/widget_renderer/src/template_renderer.rs`
