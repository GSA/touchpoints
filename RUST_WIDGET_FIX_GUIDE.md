# Rust Widget Renderer - Step-by-Step Fix Guide

## Overview
This guide will help you complete the Rust widget renderer implementation. The main issues are:

1. **Missing `modal_class` variable** - Template references a variable that doesn't exist
2. **Incomplete JavaScript template** - Only ~180 lines of an 853-line template is implemented
3. **Missing stub implementations** - Several functions return empty strings
4. **Docker Rust environment** - Rust toolchain not properly installed in Docker

---

## STEP 1: Understand the Current State

### What Works:
- ✅ Rust extension structure is set up (`ext/widget_renderer/`)
- ✅ FormData struct parses Ruby hash data
- ✅ Basic template rendering framework exists

### What's Broken:
- ❌ JavaScript template is incomplete (only first 180 lines of 853)
- ❌ Missing variables in template (`modal_class`)
- ❌ Empty stub functions (`render_form_options`, etc.)
- ❌ Rust not available in Docker container

### Files You'll Work With:
```
ext/widget_renderer/
├── Cargo.toml                    # Dependencies (already configured)
├── src/
│   ├── lib.rs                    # Entry point (working)
│   ├── form_data.rs              # Data parsing (working)
│   └── template_renderer.rs      # NEEDS FIXING
```

**Reference file:**
- `app/views/components/widget/_fba.js.erb` - Original complete template (853 lines)

---

## STEP 2: Fix Missing Variable (`modal_class`)

### Problem:
Line 153 of `template_renderer.rs` references `{modal_class}` but it's not defined.

### Location:
```rust
this.dialogEl.setAttribute('class', "{modal_class} fba-modal");
```

### Solution:
Add `modal_class` variable to the `render_fba_form_function` method.

### Steps:
1. Open `ext/widget_renderer/src/template_renderer.rs`
2. Find the function `fn render_fba_form_function(&self, form: &FormData) -> String`
3. After the `quill_css` variable (around line 44), add:

```rust
let modal_class = if form.kind == "recruitment" {
    "usa-modal usa-modal--lg"
} else {
    "usa-modal"
};
```

4. In the `format!(r#"...` section at the bottom (around line 180), update the format parameters:

**BEFORE:**
```rust
"#, 
    turnstile_init = turnstile_init,
    quill_init = quill_init,
    quill_css = quill_css
)
```

**AFTER:**
```rust
"#, 
    turnstile_init = turnstile_init,
    quill_init = quill_init,
    quill_css = quill_css,
    modal_class = modal_class
)
```

5. Add `modal_class` field to `FormData` struct in `form_data.rs`:

**In `ext/widget_renderer/src/form_data.rs`:**

Find the struct definition and add:
```rust
pub struct FormData {
    pub short_uuid: String,
    pub modal_button_text: String,
    // ... existing fields ...
    pub kind: String,  // Already exists
    // ... rest of fields ...
}
```

---

## STEP 3: Complete the JavaScript Template

### Problem:
The template is incomplete - it ends at line 177 but should be 853 lines.

### Reference:
Look at `app/views/components/widget/_fba.js.erb` - this is the complete template.

### Strategy:
You have TWO options:

#### **Option A: Manual Completion (Recommended for Learning)**
Copy the remaining JavaScript from the ERB template and convert ERB syntax to Rust.

**ERB to Rust Conversion Rules:**
- ERB: `<%= value %>` → Rust: `{value}`
- ERB: `<%- if condition %>` → Rust: `{conditional_var}` (pre-computed)
- ERB double braces `{{` → Rust: `{{{{` (escape for format! macro)
- ERB single braces `{` → Rust: `{{`

**Example:**
```erb
// ERB version
<%= form.modal_button_text %>
```

```rust
// Rust version in format! macro
{modal_button_text}
```

#### **Option B: Incremental Approach (Recommended for Production)**
Start with a minimal working version, then add features incrementally.

**Phase 1 - Minimal Working Widget:**
- Just render the form initialization
- Skip complex features (pagination, validation, etc.)
- Test that it compiles and runs

**Phase 2 - Add Core Features:**
- Form submission
- Event listeners
- Basic validation

**Phase 3 - Add Advanced Features:**
- Pagination
- Turnstile/reCAPTCHA
- Rich text (Quill)
- Local storage

### Steps for Option B (Recommended):

1. **First, just make it compile** by completing the basic structure

2. **Add minimal `render_form_options` implementation:**

```rust
fn render_form_options(&self, form: &FormData) -> String {
    format!(r#"
var touchpointFormOptions{uuid} = {{
    'formId': "{uuid}",
    'modalButtonText': "{button_text}",
    'elementSelector': "{selector}",
    'deliveryMethod': "{delivery_method}",
    'loadCSS': {load_css},
    'suppressSubmitButton': {suppress_submit},
    'verifyCsrf': {verify_csrf}
}};
"#,
        uuid = form.short_uuid,
        button_text = form.modal_button_text,
        selector = form.element_selector,
        delivery_method = form.delivery_method,
        load_css = form.load_css,
        suppress_submit = form.suppress_submit_button,
        verify_csrf = form.verify_csrf
    )
}
```

3. **Add minimal `render_form_initialization`:**

```rust
fn render_form_initialization(&self, form: &FormData) -> String {
    format!(r#"
window.touchpointForm{uuid} = new FBAform(document, window);
window.touchpointForm{uuid}.init(touchpointFormOptions{uuid});
"#,
        uuid = form.short_uuid
    )
}
```

4. **Add minimal USWDS stubs:**

```rust
fn render_uswds_bundle(&self) -> String {
    r#"
// USWDS bundle would be loaded here
"#.to_string()
}

fn render_uswds_initialization(&self, _form: &FormData) -> String {
    r#"
// USWDS initialization would be here
"#.to_string()
}
```

**Note:** Use `_form` instead of `form` to suppress unused variable warnings.

---

## STEP 4: Fix Docker Rust Environment

### Problem:
Docker container doesn't have Rust installed, so compilation fails.

### Solution:
Update the Dockerfile to include Rust toolchain.

### Steps:

1. **Open `Dockerfile`**

2. **Find the Ruby installation section** (usually near the top)

3. **Add Rust installation AFTER system dependencies:**

```dockerfile
# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Verify Rust installation
RUN rustc --version && cargo --version
```

4. **Alternative: Add to existing RUN command** (more efficient):

```dockerfile
# Install system dependencies and Rust
RUN apt-get update -qq && \
    apt-get install -y build-essential curl && \
    # ... other dependencies ... && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV PATH="/root/.cargo/bin:${PATH}"
```

5. **Rebuild Docker image:**

```bash
docker compose build webapp
docker compose up -d webapp
```

6. **Verify Rust is available:**

```bash
docker compose exec webapp rustc --version
docker compose exec webapp cargo --version
```

---

## STEP 5: Build and Test the Rust Extension

### Steps:

1. **Enter the widget_renderer directory:**

```bash
cd ext/widget_renderer
```

2. **Build the Rust extension:**

```bash
cargo build --release
```

3. **Check for compilation errors:**
- Read error messages carefully
- Most errors will be about missing variables in templates
- Fix them one by one

4. **Test in Ruby:**

Create a test script: `test/test_rust_widget.rb`

```ruby
require_relative '../ext/widget_renderer/src/lib'

form_data = {
  short_uuid: 'test123',
  modal_button_text: 'Click me',
  element_selector: 'touchpoints-form',
  delivery_method: 'modal',
  load_css: true,
  kind: 'survey',
  enable_turnstile: false,
  has_rich_text_questions: false,
  verify_csrf: true,
  prefix: '/touchpoints',
  questions: []
}

result = WidgetRenderer.render(form_data)
puts result
```

5. **Run the test:**

```bash
ruby test/test_rust_widget.rb
```

---

## STEP 6: Integration Testing

### Steps:

1. **Update Rails to use Rust renderer:**

In your controller (probably `app/controllers/widgets_controller.rb`):

```ruby
def show
  form = Form.find_by(short_uuid: params[:id])
  
  # Try Rust renderer first, fall back to Ruby
  begin
    form_data = prepare_form_data(form)
    @widget_js = WidgetRenderer.render(form_data)
  rescue => e
    Rails.logger.error "Rust renderer failed: #{e.message}"
    # Fall back to ERB rendering
    @widget_js = render_to_string(
      partial: 'components/widget/fba',
      locals: { form: form }
    )
  end
  
  render js: @widget_js
end
```

2. **Test in development:**

```bash
rails server
# Visit: http://localhost:3000/touchpoints/YOUR_FORM_ID.js
```

3. **Compare outputs:**
- Generate widget with Rust
- Generate widget with ERB
- They should produce identical JavaScript

---

## STEP 7: Performance Benchmarking

### Create benchmark script: `benchmark/widget_render.rb`

```ruby
require 'benchmark'
require_relative '../ext/widget_renderer/src/lib'

form = Form.first # or specific form
iterations = 1000

Benchmark.bmbm do |x|
  x.report("ERB rendering:") do
    iterations.times do
      ApplicationController.render(
        partial: 'components/widget/fba',
        locals: { form: form }
      )
    end
  end
  
  x.report("Rust rendering:") do
    iterations.times do
      form_data = prepare_form_data(form)
      WidgetRenderer.render(form_data)
    end
  end
end
```

**Expected results:**
- Rust should be 10-100x faster
- Lower memory usage
- Consistent performance

---

## Common Errors and Solutions

### Error: "unterminated raw string"
**Cause:** Missing `"#)` at end of raw string
**Fix:** Make sure every `format!(r#"` has matching `"#)` or `"#,`

### Error: "cannot find value `variable_name`"
**Cause:** Variable referenced in template but not passed to `format!`
**Fix:** Add variable to the format! parameters list

### Error: "unused variable: `form`"
**Cause:** Function parameter not used
**Fix:** Prefix with underscore: `_form: &FormData`

### Error: "rustc: command not found"
**Cause:** Rust not installed in Docker
**Fix:** Follow Step 4 to update Dockerfile

### Error: Mismatched braces `{{` or `}}`
**Cause:** JavaScript braces not properly escaped for Rust's `format!` macro
**Fix:** 
- Single brace in output: Use `{{` or `}}`
- Literal brace in Rust template: Use `{{{{` or `}}}}`

---

## Testing Checklist

- [ ] Rust code compiles without errors
- [ ] Docker container has Rust installed
- [ ] Extension builds successfully
- [ ] Generated JavaScript is valid
- [ ] Widget loads in browser
- [ ] Form submission works
- [ ] Modal opens/closes correctly
- [ ] Performance is better than ERB
- [ ] No memory leaks
- [ ] Error handling works

---

## Next Steps After Basic Implementation

1. **Add remaining JavaScript methods** from the ERB template:
   - `loadButton()`
   - `handleOtherOption()`
   - `handlePhoneInput()`
   - `submitForm()`
   - `textCounter()`
   - Full pagination logic
   - Turnstile integration
   - Quill rich text editor

2. **Add CSS rendering** - currently returns empty string

3. **Add HTML rendering** - form body generation

4. **Optimize:**
   - Cache compiled templates
   - Minimize string allocations
   - Use &str instead of String where possible

5. **Production hardening:**
   - Better error messages
   - Input validation
   - XSS protection
   - Logging

---

## Success Criteria

✅ **Minimum Viable Product:**
- Widget JavaScript generates correctly
- No compilation errors
- 10x faster than ERB rendering
- Works for basic form display

✅ **Production Ready:**
- All features from ERB version
- Comprehensive tests
- Error handling
- Documentation
- Monitoring/logging

---

## Resources

- **Rust format! macro:** https://doc.rust-lang.org/std/macro.format.html
- **Raw strings in Rust:** https://doc.rust-lang.org/reference/tokens.html#raw-string-literals
- **Rutie documentation:** https://github.com/danielpclark/rutie

---

## Questions?

Common issues:
1. "Where do I add the modal_class variable?" → See STEP 2
2. "How much of the template do I need?" → Start with STEP 3, Option B (minimal)
3. "Rust won't compile in Docker" → Follow STEP 4 completely
4. "How do I test this?" → Follow STEP 5 and STEP 6

Good luck! Start with getting the basics working, then incrementally add features. Don't try to implement everything at once.
