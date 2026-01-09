# Post-Mortem: Touchpoints Production Outages

**Date:** December 22-23, 2025  
**Author:** Riley Seaburg  
**Severity:** Critical - Production down  
**Status:** Resolved

---

## Incident 2: Production Down - Rust Widget Renderer Loading Failure

**Date:** December 23, 2025  
**Duration:** ~2 hours (05:19 UTC - 14:53 UTC)  
**Severity:** Critical - All 18 production instances down

### Executive Summary

Production went completely down when CircleCI deployed a new build. All 18 instances crashed on startup because the Rust widget renderer native library (`libwidget_renderer.so`) was not found, and the `SKIP_WIDGET_RENDERER` environment variable check was not happening early enough to prevent the crash.

### Timeline

| Time (UTC) | Event |
|------------|-------|
| **04:41** | CircleCI deployment started |
| **05:19** | New droplet deployed, instances start crashing |
| **05:28** | All 18 instances marked as `down` |
| **05:30 - 06:45** | CircleCI retries deployment 5 times, all fail |
| **14:25** | Investigation begins, logs show `WidgetRenderer native library not found` |
| **14:38** | `cf cancel-deployment` executed to stop stuck deployment |
| **14:39** | Attempted rollback to revision 432 - also crashes (same code issue) |
| **14:41** | Set `SKIP_WIDGET_RENDERER=true` env var manually |
| **14:42** | `cf restart` - still crashes (old droplet doesn't have fix) |
| **14:43** | Manual `cf push` with fixed code from production branch |
| **14:45** | New droplet created with fix |
| **14:52** | `cf set-droplet` to switch to new droplet |
| **14:53** | `cf restart` - **All 18 instances running** |

### Root Cause

**Three compounding issues:**

1. **Manifest removed env var:** The `touchpoints.yml` manifest didn't include `SKIP_WIDGET_RENDERER`, so CF removed the manually-set env var during deployment:
   ```
   - SKIP_WIDGET_RENDERER: "true"
   ```

2. **Check happened too late:** The `SKIP_WIDGET_RENDERER` check was in a Rails initializer, but the gem was loaded during `Bundler.require` in `config/application.rb` - **before** any initializer runs.

3. **Native library not in droplet:** The Rust library built in CircleCI wasn't being included in the deployed droplet at the correct path.

### The Fix

**PR #1935:** Added `SKIP_WIDGET_RENDERER: "true"` to all manifest files:
- `touchpoints.yml`
- `touchpoints-staging.yml`
- `touchpoints-demo.yml`

**PR #1936:** Moved the `SKIP_WIDGET_RENDERER` check to the **beginning** of `ext/widget_renderer/lib/widget_renderer.rb`:

```ruby
# Check if widget renderer should be skipped
if ENV['SKIP_WIDGET_RENDERER'] == 'true'
  puts 'WidgetRenderer: SKIP_WIDGET_RENDERER is set, using stub implementation'
  
  class WidgetRenderer
    def self.render_widget(template, data)
      nil  # Signal caller to use ERB fallback
    end
    
    def self.available?
      false
    end
  end
  
  return  # Exit early, don't load native library
end
```

### Recovery Steps

1. `cf cancel-deployment touchpoints` - Stop stuck deployment
2. `cf set-env touchpoints SKIP_WIDGET_RENDERER true` - Set env var
3. `cf push touchpoints -f touchpoints.yml` - Push fixed code
4. `cf set-droplet touchpoints <new-droplet-guid>` - Switch to new droplet
5. `cf restart touchpoints` - Restart with fix

### Lessons Learned

1. **Manifest env vars override manual settings** - Any env var not in the manifest gets removed on push
2. **Gem load order matters** - Code in gem's main file runs during `Bundler.require`, before Rails initializers
3. **CF keeps limited droplet history** - Can only rollback to recent revisions (~5-10 droplets retained)
4. **`cf push` creates droplet but doesn't always use it** - May need `cf set-droplet` to switch

### Action Items

| Item | Status |
|------|--------|
| Add `SKIP_WIDGET_RENDERER` to all manifests | ✅ Done (PR #1935) |
| Move skip check to gem load time | ✅ Done (PR #1936) |
| Document CF droplet/revision management | Pending |
| Add deployment runbook for rollback scenarios | Pending |

---

## Incident 1: Widget Modal Button Not Working

**Date:** December 18-22, 2025  
**Duration:** ~4 days  
**Severity:** High - User-facing feature broken  
**Status:** Resolved

---

## Executive Summary

The Touchpoints feedback widget stopped functioning correctly on external sites using the "modal" delivery method. Users clicking the floating feedback button saw no response - the modal dialog did not open. Instead, in some cases, the form rendered inline at the bottom of the page. This issue affected multiple government websites including ncei.noaa.gov and touchpoints.digital.gov.

**Root Cause:** The Rust widget renderer (introduced for performance optimization) was missing the USWDS Modal initialization code for the `#fba-button` element, which is required for the modal to respond to click events.

---

## Background: Why the Rust Widget Renderer Exists

In **October 2025**, the Touchpoints application experienced severe performance issues:

- **CPU-intensive ERB template rendering was causing crashes**
- Response times of 100-500ms per widget request (up to 707.9ms in benchmarks)
- High CPU usage (26-35% per instance)
- Required 18 production instances to handle load
- Frequent app instability under load

To address this, a **Rust-based widget renderer** was introduced on October 29, 2025, which achieved:

- **12.1x performance improvement** (707.9ms → 58.45ms per request)
- **91.7% reduction in response time**
- Significantly reduced CPU and memory usage
- Improved application stability

The Rust renderer generates the same JavaScript output as the ERB template, but compiles templates at build time rather than parsing them on every request.

---

## Incident Timeline

### Background Events

| Date | Event |
|------|-------|
| **Oct 29, 2025** | Rust-based widget renderer added to fix performance/crash issues |
| **Nov 4, 2025** | Benchmarks confirmed 12.1x performance improvement |
| **Nov 20-25, 2025** | Multiple fixes for Rust renderer (null booleans, path detection, library loading) |
| **Dec 1, 2025** | Production release with Rust widget renderer |
| **Dec 15, 2025** | Release: WidgetRenderer load fix (#1914) deployed to production |

### Incident Events

| Date/Time | Event |
|-----------|-------|
| **Dec 18, 2025** | Multiple deployment fixes for CF timeout, Sidekiq health checks, widget CSS |
| **Dec 18, 2025** | Fix: Add CSS support to Rust widget renderer to fix modal positioning |
| **Dec 18, 2025** | Fix: Use fba-usa-modal class for USWDS Modal compatibility |
| **Dec 19, 2025** | Fix: custom-button-modal USWDS initialization added (partial fix for different issue) |
| **Dec 19, 2025 12:24 PM** | **Zendesk Ticket #37620 received** - Jimmy Baker (NOAA) reports widget showing form inline instead of modal toast |
| **Dec 19, 2025** | Multiple attempts to force Rust rebuild (version bumps, cargo clean, cache invalidation) |
| **Dec 19, 2025 22:06 UTC** | Last production deployment before fix |
| **Dec 22, 2025** | Root cause identified: Missing `#fba-button` initialization in Rust renderer |
| **Dec 22, 2025** | PR #1924 merged: Fix Rust widget renderer modal button initialization |
| **Dec 22, 2025** | PR #1925 created: Release to production |
| **Dec 22, 2025** | PR #1926 merged: Address additional PR feedback |

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
4. **Dec 18-19 fixes created false confidence:** The `custom-button-modal` fix addressed a similar but different issue, masking the core problem
5. **Silent failure:** The widget appeared to load but just didn't work - no visible errors to users

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

## Cloud Foundry Events Summary

**Production (touchpoints):**
- Last successful deployment: Dec 19, 2025 22:06 UTC
- 18 web instances running
- No crash events during incident period (widget issue was client-side JavaScript)

**Staging (touchpoints-staging):**
- 6 crash events on Dec 22 (unrelated test environment issues)

---

## Lessons Learned

### What Went Well
- Quick identification of root cause once the ticket was received
- Comprehensive fix that addressed multiple related issues
- Good collaboration between team members
- ERB fallback mechanism exists (though not auto-triggered in this case)

### What Went Wrong
1. **Incomplete feature parity testing:** The Rust renderer was not tested against all delivery methods
2. **No browser-based integration tests:** Would have caught the modal not opening
3. **Silent failure:** The widget appeared to load but just didn't work - no visible errors to users
4. **4-day detection lag:** Issue existed for several days before user report
5. **Partial fixes masked root cause:** Dec 18-19 fixes addressed related but different issues

### Where We Got Lucky
- User reported the issue promptly with clear reproduction steps
- ERB fallback existed as a safety net
- The fix was straightforward once identified
- No data loss or security implications

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
| Create checklist for Rust renderer changes | TBD | Not Started |

### Long-term (Next Quarter)

| Item | Owner | Status |
|------|-------|--------|
| Implement automatic fallback to ERB if Rust-rendered widget fails to initialize | TBD | Not Started |
| Add client-side error reporting for widget initialization failures | TBD | Not Started |
| Create widget health monitoring dashboard | TBD | Not Started |
| Add visual regression testing for widget UI | TBD | Not Started |

---

## Deployment History (Dec 15-22)

```
Dec 22: Fix flaky inline title edit test
Dec 22: Merge production into develop to resolve conflicts
Dec 22: Address PR #1926 feedback (element_selector, form.rb refactor)
Dec 22: Fix Rust widget renderer modal button initialization (#1924)
Dec 19: Fix custom-button-modal USWDS initialization
Dec 19: Multiple cargo/version bumps to force rebuild
Dec 19: Keep prebuilt Rust library during deployment
Dec 18: Fix CSS support, fba-usa-modal class
Dec 18: Deployment timeout and Sidekiq fixes
Dec 18: Set prod disk quota to 2G (#1919)
Dec 15: WidgetRenderer load fix (#1914)
```

---

## References

- **Zendesk Ticket:** #37620
- **Fix PRs:** #1924, #1925, #1926
- **ERB Template:** `app/views/components/widget/_fba.js.erb`
- **Rust Renderer:** `ext/widget_renderer/src/template_renderer.rs`
- **Performance Benchmarks:** `BENCHMARK_RESULTS.md`
- **Original Rust Implementation:** `rust-widget-service.md`

---

## Appendix: Performance Context

The Rust widget renderer was introduced to solve critical performance issues:

| Metric | ERB Renderer | Rust Renderer | Improvement |
|--------|--------------|---------------|-------------|
| Avg Response Time | 707.9ms | 58.45ms | **12.1x faster** |
| Throughput | 1.41 req/s | 17.11 req/s | **12.1x higher** |
| CPU Usage | 26-35% | ~5% | **~6x lower** |

The performance benefits justify continued investment in the Rust renderer, but this incident highlights the need for comprehensive testing when maintaining two parallel rendering systems.
