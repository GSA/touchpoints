use crate::form_data::FormData;

pub struct TemplateRenderer;

impl TemplateRenderer {
    pub fn new() -> Self {
        TemplateRenderer
    }

    pub fn render(&self, form: &FormData) -> String {
        let mut template = String::new();
        
        // Add the complete FBAform function
        template.push_str(&self.render_fba_form_function(form));
        
        // Add the form options
        template.push_str(&self.render_form_options(form));
        
        // Add the form initialization
        template.push_str(&self.render_form_initialization(form));
        
        // Add USWDS bundle and initialization if needed
        if form.load_css && form.delivery_method != "touchpoints-hosted-only" {
            template.push_str(&self.render_uswds_bundle());
            template.push_str(&self.render_uswds_initialization(form));
        }
        
        template
    }

    fn render_fba_form_function(&self, form: &FormData) -> String {
        let turnstile_init = if form.enable_turnstile {
            "this.loadTurnstile();"
        } else {
            ""
        };
        
        let quill_init = if form.has_rich_text_questions {
            "this.loadQuill();"
        } else {
            ""
        };
        
        let quill_css = if form.has_rich_text_questions {
            r#"
                var quillStyles = d.createElement('link');
                quillStyles.setAttribute("href", "/assets/quill-snow.css")
                quillStyles.setAttribute("rel", "stylesheet")
                d.head.appendChild(quillStyles);
            "#
        } else {
            ""
        };

        let modal_class = if form.kind == "recruitment" {
            format!("{} usa-modal--lg", form.prefix)
        } else {
            form.prefix.clone()
        };

        format!(r#"
// Form components are namespaced under 'fba' = 'Feedback Analytics'
// Updated: July 2024
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
		isFormSubmitted: false, // defaults to false
		// enable Javascript experience
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
			this.successState = false; // initially false
			this._pagination();
			if (this.options.formSpecificScript) {{
				this.options.formSpecificScript();
			}}
			{turnstile_init}
			{quill_init}
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
		_loadCss: function() {{
			if (this.options.loadCSS) {{
				var style = d.createElement('style');
				style.innerHTML = this.options.css;
				d.head.appendChild(style);
				{quill_css}
			}}
		}},
		_loadHtml: function() {{
		if ((this.options.deliveryMethod && this.options.deliveryMethod === 'inline') && this.options.suppressSubmitButton) {{
			if (this.options.elementSelector) {{
				if(d.getElementById(this.options.elementSelector) != null) {{
					d.getElementById(this.options.elementSelector).innerHTML = this.options.htmlFormBodyNoModal();
				}}
			}}
		}} else if (this.options.deliveryMethod && this.options.deliveryMethod === 'inline') {{
			if (this.options.elementSelector) {{
				if(d.getElementById(this.options.elementSelector) != null) {{
					d.getElementById(this.options.elementSelector).classList.add('fba-inline-container');
					d.getElementById(this.options.elementSelector).innerHTML = this.options.htmlFormBody();
				}}
			}}
		}}
		if (this.options.deliveryMethod && (this.options.deliveryMethod === 'modal' || this.options.deliveryMethod === 'custom-button-modal')) {{
			this.dialogEl = d.createElement('div');
			this.dialogEl.setAttribute('class', "{modal_class} fba-modal");
			this.dialogEl.setAttribute('id', this.modalId());
			this.dialogEl.setAttribute('aria-labelledby', `fba-form-title-${{this.options.formId}}`);
			this.dialogEl.setAttribute('aria-describedby', `fba-form-instructions-${{this.options.formId}}`);
			this.dialogEl.setAttribute('data-touchpoints-form-id', this.options.formId);

			this.dialogEl.innerHTML = this.options.htmlFormBody();
			d.body.appendChild(this.dialogEl);
		}}
		var otherElements = this.formElement().querySelectorAll(".usa-input.other-option");
		for (var i = 0; i < otherElements.length; i++) {{
		    otherElements[i].addEventListener('keyup', this.handleOtherOption.bind(this), false);
		}}
		var phoneElements = this.formElement().querySelectorAll("input[type='tel']");
		for (var i = 0; i < phoneElements.length; i++) {{
		    phoneElements[i].addEventListener('keyup', this.handlePhoneInput.bind(this), false);
		}}
		if (this.options.deliveryMethod && this.options.deliveryMethod === 'custom-button-modal') {{
			if (this.options.elementSelector) {{
				const customButtonEl = d.getElementById(this.options.elementSelector);
				if (customButtonEl != null) {{
					customButtonEl.setAttribute('data-open-modal', '');
					customButtonEl.setAttribute('aria-controls', this.modalId());
					customButtonEl.addEventListener('click', () => d.dispatchEvent(new CustomEvent('onTouchpointsModalOpen', {{ detail: {{ form: this }} }})));
				}}
			}}
		}}
	}},
}};
"#, 
            turnstile_init = turnstile_init,
            quill_init = quill_init,
            quill_css = quill_css,
            modal_class = modal_class
        )
    }

    fn render_form_options(&self, form: &FormData) -> String {
        let question_params = self.render_question_params(form);
        
        format!(r#"
var touchpointFormOptions{uuid} = {{
    'formId': "{uuid}",
    'modalButtonText': "{button_text}",
    'elementSelector': "{selector}",
    'deliveryMethod': "{delivery_method}",
    'loadCSS': {load_css},
    'successTextHeading': "{success_heading}",
    'successText': "{success_text}",
    'suppressUI': {suppress_ui},
    'suppressSubmitButton': {suppress_submit},
    'verifyCsrf': {verify_csrf},
    'questionParams': function(form) {{
        return {{
            {question_params}
        }}
    }}
}};
"#,
            uuid = form.short_uuid,
            button_text = form.modal_button_text,
            selector = form.element_selector,
            delivery_method = form.delivery_method,
            load_css = form.load_css,
            success_heading = form.success_text_heading,
            success_text = form.success_text,
            suppress_ui = form.suppress_ui,
            suppress_submit = form.suppress_submit_button,
            verify_csrf = form.verify_csrf,
            question_params = question_params
        )
    }

    fn render_form_initialization(&self, form: &FormData) -> String {
        format!(r#"
window.touchpointForm{uuid} = new FBAform(document, window);
window.touchpointForm{uuid}.init(touchpointFormOptions{uuid});
"#,
            uuid = form.short_uuid
        )
    }

    fn render_uswds_bundle(&self) -> String {
        // Include the pre-built USWDS bundle at compile time
        include_str!("../widget-uswds-bundle.js").to_string()
    }

    fn render_uswds_initialization(&self, form: &FormData) -> String {
        format!(r#"

// Initialize any USWDS components used in this form
(function () {{
	const formId = "touchpoints-form-{uuid}";
	const fbaFormElement = document.querySelector(`#${{formId}}`);
	if (fbaFormElement) {{
		fbaUswds.ComboBox.on(fbaFormElement);
		fbaUswds.DatePicker.on(fbaFormElement);
	}}
	const modalId = "fba-modal-{uuid}";
	const fbaModalElement = document.querySelector(`#${{modalId}}`);
	if (fbaModalElement) {{
		fbaUswds.Modal.on(fbaModalElement);
	}}
}})();
"#, uuid = form.short_uuid)
    }

    fn render_question_params(&self, form: &FormData) -> String {
        // Generate question parameters based on the questions in the form
        let mut params = Vec::new();
        
        for question in &form.questions {
            // Generate different parameter logic based on question type
            let param_logic = match question.question_type.as_str() {
                "radio" | "checkbox" => {
                    format!(
                        "form.querySelector('[name=\"{}\"]') ? form.querySelector('[name=\"{}\"]:checked').value : null",
                        question.answer_field,
                        question.answer_field
                    )
                },
                "select" => {
                    format!(
                        "form.querySelector('[name=\"{}\"]') ? form.querySelector('[name=\"{}\"]').selectedOptions[0].value : null",
                        question.answer_field,
                        question.answer_field
                    )
                },
                _ => {
                    format!(
                        "form.querySelector('[name=\"{}\"]') ? form.querySelector('[name=\"{}\"]').value : null",
                        question.answer_field,
                        question.answer_field
                    )
                }
            };
            
            params.push(format!("{}: {}", question.answer_field, param_logic));
        }
        
        params.join(",\n            ")
    }
}
