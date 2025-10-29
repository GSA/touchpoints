use crate::form_data::FormData;

pub struct TemplateRenderer;

impl TemplateRenderer {
    pub fn new() -> Self {
        TemplateRenderer
    }

    pub fn render(&self, form: &FormData) -> String {
        let mut template = String::new();
        
        // Add the main FBAform function
        template.push_str(&self.render_fba_form_function(form));
        
        // Add the form options
        template.push_str(&self.render_form_options(form));
        
        // Add the form initialization
        template.push_str(&self.render_form_initialization(form));
        
        // Add USWDS initialization if needed
        if form.load_css && form.delivery_method != "touchpoints-hosted-only" {
            template.push_str(&self.render_uswds_initialization(form));
        }
        
        template
    }

    fn render_fba_form_function(&self, _form: &FormData) -> String {
        format!(r#"
'use strict';

function FBAform(d, N) {{
    return {{
        formComponent: function() {{
            return d.querySelector("[data-touchpoints-form-id='" + this.options.formId + "']")
        }},
        formElement: function() {{
            return this.formComponent().querySelector("form");
        }},
        formLocalStorageKey: function() {{
            return `touchpoints:${{this.options.formId}}`
        }},
        isFormSubmitted: false,
        javascriptIsEnabled: function() {{
            var javascriptDisabledMessage = d.getElementsByClassName("javascript-disabled-message")[0];
            var touchpointForm = d.getElementsByClassName("touchpoint-form")[0];
            if (javascriptDisabledMessage) {{
                javascriptDisabledMessage.classList.add("hide");
            }}
            if (touchpointForm) {{
                touchpointForm.classList.remove("hide");
            }}
        }},
        init: function(options) {{
            this.javascriptIsEnabled();
            this.formInitiatedAt = Date.now();
            this.options = options;
            if (this.options.loadCSS) {{
                this._loadCss();
            }}
            this._loadHtml();
            if (!this.options.suppressUI && (this.options.deliveryMethod && this.options.deliveryMethod === 'modal')) {{
                this.loadButton();
            }}
            this.enableLocalStorage();
            this._bindEventListeners();
            this.successState = false;
            this._pagination();
            if (this.options.formSpecificScript) {{
                this.options.formSpecificScript();
            }}
            d.dispatchEvent(new CustomEvent('onTouchpointsFormLoaded', {{
                detail: {{
                    formComponent: this
                }}
            }}));
            return this;
        }},
        _bindEventListeners: function() {{
            var self = this;
            const textareas = this.formComponent().querySelectorAll(".usa-textarea, .ql-editor");
            textareas.forEach(function(textarea) {{
                if (textarea.getAttribute("maxlength") != '0' && textarea.getAttribute("maxlength") != '10000')  {{
                    textarea.addEventListener("keyup", self.textCounter);
                }}
            }});
            const textFields = this.formComponent().querySelectorAll(".usa-input[type='text']");
            textFields.forEach(function(textField) {{
                if (textField.getAttribute("maxlength") != '0' && textField.getAttribute("maxlength") != '10000')  {{
                    textField.addEventListener("keyup", self.textCounter);
                }}
            }});
        }},
        // Additional methods would be added here...
        modalId: function() {{
            return `fba-modal-${{this.options.formId}}`;
        }},
        modalElement: function() {{
            return document.getElementById(this.modalId());
        }}
    }};
}};
"#)
    }

    fn render_form_options(&self, form: &FormData) -> String {
        format!(r#"
var touchpointFormOptions{} = {{
    'formId': "{}",
    'modalButtonText': "{}",
    'elementSelector': "{}",
    'css' : "",
    'loadCSS' : {},
    'formSpecificScript' : function() {{}},
    'deliveryMethod' : "{}",
    'successTextHeading' : "{}",
    'successText' : "{}",
    'questionParams' : function(form) {{
        return {{}}
    }},
    'suppressUI' : {},
    'suppressSubmitButton' : {},
    'htmlFormBody' : function() {{
        return null;
    }},
    'htmlFormBodyNoModal' : function() {{
        return null;
    }}
}};
"#, 
            form.short_uuid,
            form.short_uuid,
            self.escape_js(&form.modal_button_text),
            self.escape_js(&form.element_selector),
            form.load_css,
            form.delivery_method,
            self.escape_js(&form.success_text_heading),
            self.escape_js(&form.success_text),
            form.suppress_ui,
            form.suppress_submit_button
        )
    }

    fn render_form_initialization(&self, form: &FormData) -> String {
        format!(r#"
window.touchpointForm{} = new FBAform(document, window);
window.touchpointForm{}.init(touchpointFormOptions{});
"#, form.short_uuid, form.short_uuid, form.short_uuid)
    }

    fn render_uswds_initialization(&self, form: &FormData) -> String {
        format!(r#"
(function () {{
    const formId = "touchpoints-form-{}";
    const fbaFormElement = document.querySelector(`#${{formId}}`);
    if (fbaFormElement) {{
        if (typeof fbaUswds !== 'undefined') {{
            fbaUswds.ComboBox.on(fbaFormElement);
            fbaUswds.DatePicker.on(fbaFormElement);
        }}
    }}
    const modalId = "fba-modal-{}";
    const fbaModalElement = document.querySelector(`#${{modalId}}`);
    if (fbaModalElement) {{
        if (typeof fbaUswds !== 'undefined') {{
            fbaUswds.Modal.on(fbaModalElement);
        }}
    }}
}})();
"#, form.short_uuid, form.short_uuid)
    }

    fn escape_js(&self, input: &str) -> String {
        input
            .replace('\\', "\\\\")
            .replace('"', "\\\"")
            .replace('\n', "\\n")
            .replace('\r', "\\r")
            .replace('\t', "\\t")
    }
}
