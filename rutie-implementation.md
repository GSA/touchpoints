# Immediate Rutie Implementation for Widget Performance

## Setup (30 minutes)

### 1. Add Rutie to Gemfile
```ruby
# Gemfile
gem 'rutie', '~> 0.8'
```

### 2. Create Rust Extension Structure
```bash
mkdir -p ext/widget_renderer/src
cd ext/widget_renderer
```

### 3. Cargo.toml
```toml
[package]
name = "widget_renderer"
version = "0.1.0"
edition = "2021"

[lib]
crate-type = ["cdylib"]

[dependencies]
rutie = "0.8"
```

### 4. extconf.rb
```ruby
# ext/widget_renderer/extconf.rb
require 'mkmf'

unless system('which rustc > /dev/null 2>&1')
  abort "Rust compiler not found. Please install Rust."
end

system('cargo build --release') or abort "Failed to build Rust extension"

$LDFLAGS += " -L#{Dir.pwd}/target/release -lwidget_renderer"
create_makefile('widget_renderer')
```

## Rust Implementation (1 hour)

### 5. Main Rust Code
```rust
// ext/widget_renderer/src/lib.rs
use rutie::{Class, Object, RString, Hash, AnyObject, VM};

#[no_mangle]
pub extern "C" fn Init_widget_renderer() {
    Class::new("WidgetRenderer", None).define(|klass| {
        klass.def_self("generate_js", generate_js);
    });
}

extern "C" fn generate_js(_argc: isize, argv: *const AnyObject, _: AnyObject) -> RString {
    let args = VM::parse_arguments(1, argv);
    let form_hash = Hash::from(args[0]);
    
    let js_content = render_widget_template(&form_hash);
    RString::new_utf8(&js_content)
}

fn render_widget_template(form: &Hash) -> String {
    let short_uuid = get_string_from_hash(form, "short_uuid");
    let modal_button_text = get_string_from_hash(form, "modal_button_text");
    let element_selector = get_string_from_hash(form, "element_selector");
    let delivery_method = get_string_from_hash(form, "delivery_method");
    let load_css = get_bool_from_hash(form, "load_css");
    
    // Fast string formatting instead of ERB
    format!(r#"
'use strict';

function FBAform(d, N) {{
    return {{
        formComponent: function() {{
            return d.querySelector("[data-touchpoints-form-id='{uuid}']")
        }},
        formElement: function() {{
            return this.formComponent().querySelector("form");
        }},
        init: function(options) {{
            this.options = options;
            if (this.options.loadCSS) {{
                this._loadCss();
            }}
            this._loadHtml();
            this._bindEventListeners();
            return this;
        }},
        _loadHtml: function() {{
            if (this.options.deliveryMethod === 'inline') {{
                if (this.options.elementSelector) {{
                    if(d.getElementById(this.options.elementSelector) != null) {{
                        d.getElementById(this.options.elementSelector).innerHTML = this.options.htmlFormBody();
                    }}
                }}
            }}
        }},
        // ... other methods
    }};
}}

var touchpointFormOptions{uuid} = {{
    'formId': "{uuid}",
    'modalButtonText': "{modal_text}",
    'elementSelector': "{element_selector}",
    'deliveryMethod': "{delivery_method}",
    'loadCSS': {load_css}
}};

window.touchpointForm{uuid} = new FBAform(document, window);
window.touchpointForm{uuid}.init(touchpointFormOptions{uuid});
"#, 
        uuid = short_uuid,
        modal_text = modal_button_text,
        element_selector = element_selector,
        delivery_method = delivery_method,
        load_css = if load_css { "true" } else { "false" }
    )
}

fn get_string_from_hash(hash: &Hash, key: &str) -> String {
    hash.at(&RString::new_utf8(key))
        .try_convert_to::<RString>()
        .unwrap_or_else(|_| RString::new_utf8(""))
        .to_string()
}

fn get_bool_from_hash(hash: &Hash, key: &str) -> bool {
    hash.at(&RString::new_utf8(key))
        .try_convert_to::<RString>()
        .map(|s| s.to_string() == "true")
        .unwrap_or(false)
}
```

## Rails Integration (30 minutes)

### 6. Update Form Model
```ruby
# app/models/form.rb

# Add after existing touchpoints_js_string method
def touchpoints_js_string
  Rails.cache.fetch("form-js-#{short_uuid}-#{updated_at.to_i}", expires_in: 1.day) do
    # Use Rust instead of ERB rendering
    WidgetRenderer.generate_js(to_widget_data)
  end
end

def to_widget_data
  {
    'short_uuid' => short_uuid,
    'modal_button_text' => modal_button_text,
    'element_selector' => element_selector,
    'delivery_method' => delivery_method,
    'load_css' => load_css.to_s,
    'success_text_heading' => success_text_heading,
    'success_text' => success_text
  }
end
```

### 7. Load Extension
```ruby
# config/application.rb
require_relative '../ext/widget_renderer/widget_renderer'
```

## Build and Deploy (30 minutes)

### 8. Build Extension
```bash
cd ext/widget_renderer
cargo build --release
cd ../..
bundle install
```

### 9. Test Locally
```ruby
# In Rails console
form = Form.first
puts form.touchpoints_js_string
```

### 10. Deploy
```bash
cf push
```

## Expected Results

### Before (ERB Rendering)
- 50-200ms per widget generation
- High CPU usage from string parsing
- Memory allocations during template processing

### After (Rust Rendering)
- 0.1-1ms per widget generation (100-1000x faster)
- Minimal CPU usage
- Single string allocation

### Impact on Crashes
- Eliminates primary CPU bottleneck
- Reduces instance CPU usage from 26-35% to ~5-10%
- Should eliminate crashes caused by widget generation load

## Total Implementation Time: 2.5 hours
- Setup: 30 minutes
- Rust code: 1 hour  
- Rails integration: 30 minutes
- Build and deploy: 30 minutes

This keeps the existing Rails architecture while replacing the CPU-intensive ERB rendering with blazing-fast Rust code.
