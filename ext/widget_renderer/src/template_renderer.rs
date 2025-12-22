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

        let modal_class = if form.load_css {
            if form.kind == "recruitment" {
                "fba-usa-modal fba-usa-modal--lg".to_string()
            } else {
                "fba-usa-modal".to_string()
            }
        } else {
            if form.kind == "recruitment" {
                "usa-modal usa-modal--lg".to_string()
            } else {
                "usa-modal".to_string()
            }
        };

        let turnstile_check = if form.enable_turnstile {
            r#"
                const elapsed = Date.now() - self.turnstileInitiatedAt;
                if (elapsed > 5 * 60 * 1000) {
                    self.initTurnstile();
                    self.turnstileInitiatedAt = Date.now();
                    return false;
                }
            "#
        } else {
            ""
        };

        let quill_load_script = if form.has_rich_text_questions {
            r#"
        loadQuill: function() {
            let script = document.createElement("script");
            script.src = "/assets/quill.js";
            script.async = true;
            script.defer = true;
            document.head.appendChild(script);
            setTimeout(this.initQuill, 1000);
        },
        initQuill: function() {
            document.querySelectorAll(".quill").forEach((wrapper) => {
                const editorContainer = wrapper.querySelector(".editor");
                const hiddenInput = wrapper.querySelector("input[type=hidden]");
                const countDisplay = wrapper.querySelector('.usa-character-count__message');
                const maxLimit = editorContainer.getAttribute("maxlength");

                if (editorContainer && hiddenInput) {
                    const quill = new Quill(editorContainer, {
                        theme: 'snow',
                        placeholder: 'Write something...',
                        modules: {
                            toolbar: [
                                ['bold', 'italic', 'underline'],
                                [{ 'list': 'ordered'}, { 'list': 'bullet' }]
                            ]
                        }
                    });

                    quill.root.innerHTML = hiddenInput.value;

                    quill.on('text-change', function () {
                        updateCount();
                        hiddenInput.value = quill.root.innerHTML;
                    });

                    const updateCount = () => {
                        const html = quill.root.innerHTML;
                        countDisplay.textContent = "" + (maxLimit - html.length) + " characters left";
                    };
                }
            });
        },
            "#
        } else {
            ""
        };

        let turnstile_site_key = std::env::var("TURNSTILE_SITE_KEY").unwrap_or_default();
        let turnstile_load_script = if form.enable_turnstile {
            format!(r###"
        loadTurnstile: function() {{
            let script = document.createElement("script");
            script.src = "https://challenges.cloudflare.com/turnstile/v0/api.js";
            script.async = true;
            script.defer = true;
            script.onload = this.initTurnstile;
            this.turnstileInitiatedAt = Date.now();
            if (!window.turnstile) {{
                document.head.appendChild(script);
            }}
        }},
        initTurnstile: function() {{
            turnstile.remove("#turnstile-container");
            turnstile.render("#turnstile-container", {{
                sitekey: "{}",
                callback: function (token) {{
                    document.querySelector("input[name='cf-turnstile-response']").value = token;
                }}
            }});
        }},
            "###, turnstile_site_key)
        } else {
            "".to_string()
        };

        let quill_save = if form.has_rich_text_questions {
            r#"
                document.querySelectorAll(".quill").forEach((wrapper) => {
                    const editorContainer = wrapper.querySelector(".editor");
                    const hiddenInput = wrapper.querySelector("input[type=hidden]");

                    if (editorContainer && hiddenInput) {
                        const quillInstance = Quill.find(editorContainer);
                        if (quillInstance) {
                            hiddenInput.value = quillInstance.root.innerHTML;
                        }
                    }
                });
            "#
        } else {
            ""
        };

        let turnstile_response = if form.enable_turnstile {
            r#"
                "cf-turnstile-response" : form.querySelector("input[name='cf-turnstile-response']") ? form.querySelector("input[name='cf-turnstile-response']").value : null,
            "#
        } else {
            ""
        };

        let csrf_token = if form.verify_csrf {
            r###"
                "authenticity_token": form.querySelector("#authenticity_token") ?
                form.querySelector("#authenticity_token").value : null
            "###
        } else {
            ""
        };

        format!(r###"
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

		var formElement = this.formElement();
		var submitButtons = formElement.querySelectorAll("[type='submit']");
		var that = this;

		var yesNoForm = formElement.querySelector('.touchpoints-yes-no-buttons');

		if (yesNoForm) {{
			Array.prototype.forEach.call(submitButtons, function(submitButton) {{
				submitButton.addEventListener('click', that.handleYesNoSubmitClick.bind(that), false);
			}})
		}} else {{
			if (submitButtons) {{
				Array.prototype.forEach.call(submitButtons, function(submitButton) {{
					submitButton.addEventListener('click', that.handleSubmitClick.bind(that), false);
				}})
			}}
		}}
	}},
	resetErrors: function() {{
		var formComponent = this.formComponent();
		var alertElement = formComponent.querySelector(".fba-alert");
		var alertElementHeading = formComponent.getElementsByClassName("usa-alert__heading")[0];
		var alertElementBody = formComponent.getElementsByClassName("usa-alert__text")[0];
		var alertErrorElement = formComponent.querySelector(".fba-alert-error");
		var alertErrorElementBody = alertErrorElement.getElementsByClassName("usa-alert__text")[0];
		alertElement.setAttribute("hidden", true);
		alertElementHeading.innerHTML = "";
		alertElementBody.innerHTML = "";
		alertErrorElement.setAttribute("hidden", true);
		alertErrorElementBody.innerHTML = "";
	}},
	handleOtherOption: function(e) {{
		var selectorId =  "#" + e.srcElement.getAttribute("data-option-id");
		var other_val = e.target.value.replace(/,/g, '');
		if (other_val == '') other_val = 'other';
		var option = this.formElement().querySelector(selectorId);
		option.value = other_val;
	}},
	handlePhoneInput: function(e) {{
		const input = e.target;
		let number = input.value.replace(/[^\d]/g, '');
		input.dataset.rawValue = number;

		if (number.length == 3) {{
			input.value = number.replace(/(\d{{3}})/, "($1)");
		}} else if (number.length == 7) {{
			input.value = number.replace(/(\d{{3}})(\d{{4}})/, "$1-$2");
		}} else if (number.length == 10) {{
			input.value = number.replace(/(\d{{3}})(\d{{3}})(\d{{4}})/, "($1) $2-$3");
		}} else {{
			input.value = number;
		}}
	}},
	handleEmailInput: function(e) {{
		var EmailRegex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{{2,4}})+$/;
		var email = e.srcElement.value.trim();
		if (email.length == 0) {{
			return;
		}}
		result = EmailRegex.test(email);
		if (!result) {{
			showWarning($(this),"Please enter a valid email address");
		}} else {{
			showValid($(this));
		}}
		e.srcElement.value = number;
	}},
	handleSubmitClick: function(e) {{
		e.preventDefault();
		this.resetErrors();
		var formElement = this.formElement();
		var self = this;
		if (self.validateForm(formElement)) {{
			{turnstile_check}

			var submitButton = formElement.querySelector("[type='submit']");
			submitButton.disabled = true;
			submitButton.classList.add("aria-disabled");
			self.sendFeedback();
		}}
	}},
	handleYesNoSubmitClick: function(e) {{
		e.preventDefault();

		var input = this.formComponent().querySelector('.fba-touchpoints-page-form');
		input.value = e.target.value;
		this.resetErrors();
		var self = this;
		var formElement = this.formElement();
		if (self.validateForm(formElement)) {{
			var submitButtons = formElement.querySelectorAll("[type='submit']");
			Array.prototype.forEach.call(submitButtons, function(submitButton) {{
				submitButton.disabled = true;
			}})
			self.sendFeedback();
		}}
	}},
	validateForm: function(form) {{
		this.hideValidationError(form);
		var valid = this.checkRequired(form) && this.checkEmail(form) && this.checkPhone(form) && this.checkDate(form);
		return valid;
	}},
	checkRequired: function(form) {{
		var requiredItems = form.querySelectorAll('[required]');
		var questions = {{}};
		Array.prototype.forEach.call(requiredItems, function(item) {{ questions[item.name] = item }});

		Array.prototype.forEach.call(requiredItems, function(item) {{
			switch (item.type) {{
			case 'radio':
				if (item.checked) delete(questions[item.name]);
				break;
			case 'checkbox':
			  if (item.checked) delete(questions[item.name]);
				break;
			case 'select-one':
				if (item.selectedIndex > 0) delete(questions[item.name]);
				break;
			default:
				const quillDefaultHTML = "<p><br></p>";
				if (item.value.length > 0 &&
					item.value != quillDefaultHTML) delete(questions[item.name]);
			}}
		}});
		for (var key in questions) {{
			this.showValidationError(questions[key], 'This field is required');
			return false;
		}}
		return true;
	}},
	checkDate: function(form) {{
		var dateItems = form.querySelectorAll('.date-select');
		var questions = {{}};
		Array.prototype.forEach.call(dateItems, function(item) {{ questions[item.name] = item }});
		Array.prototype.forEach.call(dateItems, function(item) {{
		  if (item.value.length == 0) {{
		  	delete(questions[item.name]);
		  }} else {{
			var isValidDate = Date.parse(item.value);
		    if (!isNaN(isValidDate)) delete(questions[item.name]);
		  }}
		}});
		for (var key in questions) {{
			this.showValidationError(questions[key], 'This field is invalid');
			return false;
		}}
		return true;
	}},
	checkEmail: function(form) {{
		var emailItems = form.querySelectorAll('input[type="email"]');
		var questions = {{}};
		Array.prototype.forEach.call(emailItems, function(item) {{ questions[item.name] = item }});
		Array.prototype.forEach.call(emailItems, function(item) {{
		  if (item.value.length == 0) {{
		  	delete(questions[item.name]);
		  }} else {{
		    var EmailRegex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{{2,4}})+$/;
		    if (EmailRegex.test(item.value)) delete(questions[item.name]);
		  }}
		}});
		for (var key in questions) {{
			this.showValidationError(questions[key], 'This field is invalid');
			return false;
		}}
		return true;
	}},
	checkPhone: function(form) {{
		var phoneItems = form.querySelectorAll('input[type="tel"]');
		var questions = {{}};
		Array.prototype.forEach.call(phoneItems, function(item) {{ questions[item.name] = item }});
		Array.prototype.forEach.call(phoneItems, function(item) {{
		  if (item.value.length == 0) {{
		  	delete(questions[item.name]);
		  }} else {{
		    const PhoneRegex = /^\(\d{{3}}\) \d{{3}}-\d{{4}}$/;
		    if (PhoneRegex.test(item.value)) delete(questions[item.name]);
		  }}
		}});
		for (var key in questions) {{
			this.showValidationError(questions[key], 'This field is invalid');
			return false;
		}}
		return true;
	}},
	showValidationError: function(question, error) {{
		var questionDiv = question.closest(".question");
		var label = questionDiv.querySelector(".usa-label") || questionDiv.querySelector(".usa-legend");
		var questionNum = label.innerText;

		var errorPage = question.closest(".section");
		if (!errorPage.classList.contains("fba-visible")) {{
			var visiblePage = this.formComponent().getElementsByClassName("section fba-visible")[0];
			visiblePage.classList.remove("fba-visible");
			errorPage.classList.add("fba-visible");
		}}

		questionDiv.setAttribute('class', 'usa-form-group usa-form-group--error');
		var span = d.createElement('span');
		span.setAttribute('id', 'input-error-message');
		span.setAttribute('role','alert');
		span.setAttribute('class','usa-error-message');
		span.innerText = error + questionNum;
		label.parentNode.insertBefore(span, label.nextSibling);
		var input = d.createElement('input');
		input.setAttribute('hidden', 'true');
		input.setAttribute('id','input-error');
		input.setAttribute('type','text');
		input.setAttribute('name','input-error');
		input.setAttribute('aria-describedby','input-error-message');
		questionDiv.appendChild(input);
		questionDiv.scrollIntoView();
		questionDiv.focus();

		var submitButton = this.formComponent().querySelector("[type='submit']");
		submitButton.disabled = false;
		submitButton.classList.remove("aria-disabled");
	}},
	hideValidationError: function(form) {{
		var elem = form.querySelector('.usa-form-group--error');
		if (elem == null) return;
		elem.setAttribute('class','question');
		var elem = form.querySelector('#input-error-message');
		if (elem != null) elem.parentNode.removeChild(elem);
		elem = form.querySelector('#input-error');
		if (elem != null) elem.parentNode.removeChild(elem);
	}},
	textCounter: function(event) {{
		const field = event.target;
		const maxLimit = event.target.getAttribute("maxlength");

		var countfield = field.parentNode.querySelector(".counter-msg");
		if (field.value.length > maxLimit) {{
			field.value = field.value.substring(0, maxLimit);
			countfield.innerText = '0 characters left';
			return false;
		}} else {{
			countfield.innerText = "" + (maxLimit - field.value.length) + " characters left";
		}}
	}},
	loadButton: function() {{
		this.landmarkElement = d.createElement('div');
		this.landmarkElement.setAttribute('aria-label', 'Feedback button');
		this.landmarkElement.setAttribute('role', 'complementary');

		this.buttonEl = d.createElement('button');
		this.buttonEl.setAttribute('id', 'fba-button');
		this.buttonEl.setAttribute('data-id', this.options.formId);
		this.buttonEl.setAttribute('class', 'fba-button fixed-tab-button usa-button');
		this.buttonEl.setAttribute('name', 'fba-button');
		this.buttonEl.setAttribute('aria-label', this.options.modalButtonText);
		this.buttonEl.setAttribute('aria-haspopup', 'dialog');
		this.buttonEl.setAttribute('aria-controls', this.modalId());
		this.buttonEl.setAttribute('data-open-modal', '');
		this.buttonEl.innerHTML = this.options.modalButtonText;
		this.buttonEl.addEventListener('click', () => d.dispatchEvent(new CustomEvent('onTouchpointsModalOpen', {{ detail: {{ form: this }} }})));
		this.landmarkElement.appendChild(this.buttonEl);
		d.body.appendChild(this.landmarkElement);

		this.loadFeebackSkipLink();
	}},
	loadFeebackSkipLink: function() {{
		this.skipLink = d.createElement('a');
		this.skipLink.setAttribute('class', 'usa-skipnav touchpoints-skipnav');
		this.skipLink.setAttribute('href', '#fba-button');
		this.skipLink.addEventListener('click', function() {{
			d.querySelector("#fba-button").focus();
		}});
		this.skipLink.innerHTML = 'Skip to feedback';

		var existingSkipLinks = d.querySelector('.usa-skipnav');
		if(existingSkipLinks) {{
			existingSkipLinks.insertAdjacentElement('afterend', this.skipLink);
		}} else {{
			d.body.prepend(this.skipLink);
		}}
	}},
	sendFeedback: function() {{
		d.dispatchEvent(new Event('onTouchpointsFormSubmission'));
		var form = this.formElement();
		this.ajaxPost(form, this.formSuccess);
	}},
	successHeadingText: function() {{
		return this.options.successTextHeading;
	}},
	successText: function() {{
		return this.options.successText;
	}},
	showFormSuccess: function(headerText, bodyHTML) {{
		var formComponent = this.formComponent();
		var formElement = this.formElement();
		var alertElement = formComponent.querySelector(".fba-alert");
		var alertElementHeading = formComponent.querySelector(".usa-alert__heading");
		var alertElementBody = formComponent.querySelector(".usa-alert__text");

		alertElementHeading.innerHTML = headerText;
		alertElementBody.innerHTML = bodyHTML
		alertElement.removeAttribute("hidden");
		this.formComponent().scrollIntoView();

		if (formElement) {{
			formElement.reset();
			localStorage.removeItem(this.formLocalStorageKey());
			if (formElement.querySelector('.touchpoints-form-body')) {{
				var formBody = formElement.querySelector('.touchpoints-form-body');
				if(formBody) {{
					formBody.setAttribute("hidden", true);
				}}
			}}
			if (formComponent.querySelector('.touchpoints-form-disclaimer')) {{
				var formDisclaimer = formComponent.querySelector('.touchpoints-form-disclaimer');
				if(formDisclaimer) {{
					formDisclaimer.setAttribute("hidden", true);
				}}
			}}
		}}
	}},
	resetFormDisplay: function() {{
		if (this.successState === false) {{
			return false;
		}}

		this.resetErrors();

		var formElement = this.formElement();
		var submitButton = formElement.querySelector("[type='submit']");
		submitButton.disabled = false;

		if (formElement) {{
			if (formElement.querySelector('.touchpoints-form-body')) {{
				var formBody = formElement.querySelector('.touchpoints-form-body')
				if(formBody) {{
					formBody.removeAttribute("hidden");
				}}
			}}
		}}
	}},
	formSuccess: function(e) {{
		var formComponent = this.formComponent();
		var alertElement = formComponent.querySelector(".fba-alert");
		var alertElementBody = formComponent.getElementsByClassName("usa-alert__text")[0];
		var alertErrorElement = formComponent.querySelector(".fba-alert-error");
		var alertErrorElementBody = alertErrorElement.getElementsByClassName("usa-alert__text")[0];
		alertElementBody.innerHTML = "";
		alertErrorElementBody.innerHTML = "";

		var formElement = this.formElement();
		var submitButton = formElement.querySelector("[type='submit']");

		if (e.target.readyState === 4) {{
			if (e.target.status === 201) {{
				this.successState = true;
				d.dispatchEvent(new Event('onTouchpointsFormSubmissionSuccess'));
				this.isFormSubmitted = true;
				if(submitButton) {{
					submitButton.disabled = true;
				}}

				const submission = JSON.parse(e.target.response).submission;
				const successHeaderText = submission.form.success_text_heading;
				const successBodyText = submission.form.success_text;
				this.showFormSuccess(successHeaderText, successBodyText);
			}} else if (e.target.status === 422) {{
				this.successState = false;
				d.dispatchEvent(new Event('onTouchpointsFormSubmissionError'));
				if(submitButton) {{
					submitButton.disabled = false;
				}}

				var jsonResponse = JSON.parse(e.target.response);
				var errors = jsonResponse.messages;

				for (var err in errors) {{
					if (errors.hasOwnProperty(err)) {{
						alertErrorElementBody.innerHTML += err;
						alertErrorElementBody.innerHTML += " ";
						alertErrorElementBody.innerHTML += errors[err];
						alertErrorElementBody.innerHTML += "<br />";
					}}
				}}

				alertErrorElement.removeAttribute("hidden");

				const errorMessage = this.formComponent().querySelector('.usa-alert--error');
				if (errorMessage) {{
					errorMessage.scrollIntoView({{ behavior: 'smooth', block: 'center' }});
				}}
			}} else {{
				this.successState = false;
				d.dispatchEvent(new Event('onTouchpointsFormSubmissionError'));
				alertErrorElement.removeAttribute("hidden");
				alertErrorElementBody.innerHTML += "Server error. We're sorry, but this submission was not successful. The Product Team has been notified.";

				const errorMessage = this.formComponent().querySelector('.usa-alert--error');
				if (errorMessage) {{
					errorMessage.scrollIntoView({{ behavior: 'smooth', block: 'center' }});
				}}
			}}
		}}
	}},
	ajaxPost: function (form, callback) {{
		var url = form.action;
		var xhr = new XMLHttpRequest();
		var params = this.options.questionParams(form);

		params["referer"] = d.referrer;
		params["hostname"] = N.location.hostname;
		params["page"] = N.location.pathname;
		params["query_string"] = N.location.search;
		params["location_code"] = form.querySelector("#fba_location_code") ? form.querySelector("#fba_location_code").value : null;
		params["fba_directive"] = form.querySelector("#fba_directive") ? form.querySelector("#fba_directive").value : null;
		params["language"] = "en";

		xhr.open("POST", url);
		xhr.setRequestHeader("Content-Type", "application/json; charset=UTF-8;");
		xhr.onload = callback.bind(this);
		xhr.send(JSON.stringify({{
			{turnstile_response}
			"submission": params,
			{csrf_token}
		}}));
	}},
	currentPageNumber: 1,
	showInstructions: function() {{
		const instructions = this.formComponent().getElementsByClassName("fba-instructions")[0];

		if(instructions) {{
			if (this.currentPageNumber == 1) {{
				instructions.removeAttribute("hidden");
			}} else {{
				instructions.setAttribute("hidden", true);
			}}
		}}

		const requiredQuestionsNotice = this.formComponent().getElementsByClassName("required-questions-notice")[0];
		if(requiredQuestionsNotice) {{
			if (this.currentPageNumber == 1) {{
				requiredQuestionsNotice.removeAttribute("hidden");
			}} else {{
				requiredQuestionsNotice.setAttribute("hidden", true);
			}}
		}}
	}},
	_pagination: function() {{
		var previousButtons = this.formComponent().getElementsByClassName("previous-section");
		var nextButtons =  this.formComponent().getElementsByClassName("next-section");

		var self = this;
		for (var i = 0; i < previousButtons.length; i++) {{
			previousButtons[i].addEventListener('click', function(e) {{
				e.preventDefault();
				var currentPage = e.target.closest(".section");
				if (!this.validateForm(currentPage)) return false;
				currentPage.classList.remove("fba-visible");
				this.currentPageNumber--;
				this.showInstructions();
				currentPage.previousElementSibling.classList.add("fba-visible");

				const previousPageEvent = new CustomEvent('onTouchpointsFormPreviousPage', {{
					detail: {{
						formComponent: this
					}}
				}});
				d.dispatchEvent(previousPageEvent);

				if(this.formComponent().getElementsByClassName("fba-modal")[0]) {{
					this.formComponent().scrollTo(0,0);
				}} else {{
					N.scrollTo(0, 0);
				}}
			}}.bind(self));
		}}
		for (var i = 0; i < nextButtons.length; i++) {{
			nextButtons[i].addEventListener('click', function(e) {{
				e.preventDefault();
				var currentPage = e.target.closest(".section");
				if (!this.validateForm(currentPage)) return false;
				currentPage.classList.remove("fba-visible");
				this.currentPageNumber++;
				this.showInstructions();
				currentPage.nextElementSibling.classList.add("fba-visible");

				const nextPageEvent = new CustomEvent('onTouchpointsFormNextPage', {{
					detail: {{
						formComponent: this
					}}
				}});
				d.dispatchEvent(nextPageEvent);

				if(this.formComponent().getElementsByClassName("fba-modal")[0]) {{
					this.formComponent().scrollTo(0,0);
				}} else {{
					N.scrollTo(0, 0);
				}}
			}}.bind(self))
		}}
	}},
	modalId: function() {{
		return `fba-modal-${{this.options.formId}}`;
	}},
	modalElement: function() {{
		return document.getElementById(this.modalId());
	}},
	{quill_load_script}
	{turnstile_load_script}
	enableLocalStorage: function() {{
		const form = this.formElement();
		const savedData = localStorage.getItem(this.formLocalStorageKey());

		if (savedData) {{
			const formData = JSON.parse(savedData);
			for (const key in formData) {{
				const input = form.querySelector(`[name="${{key}}"]`);
				if (input) {{
					input.value = formData[key];
				}}
			}}
		}}

		form.addEventListener('input', (event) => {{
			const inputData = {{}};

			{quill_save}

			const formData = new FormData(form);
			formData.forEach((value, key) => {{
				inputData[key] = value;
			}});

			localStorage.setItem(this.formLocalStorageKey(), JSON.stringify(inputData));
		}});
	}},
	}};
}};
"###, 
            turnstile_init = turnstile_init,
            quill_init = quill_init,
            quill_css = quill_css,
            modal_class = modal_class,
            turnstile_check = turnstile_check,
            quill_load_script = quill_load_script,
            turnstile_load_script = turnstile_load_script,
            quill_save = quill_save,
            turnstile_response = turnstile_response,
            csrf_token = csrf_token
        )
    }

    fn render_form_options(&self, form: &FormData) -> String {
        let question_params = self.render_question_params(form);
        let html_body = self.render_html_body(form).replace("`", "\\`");
        let html_body_no_modal = self.render_html_body_no_modal(form).replace("`", "\\`");
        // Escape the CSS for JavaScript string - escape backslashes, backticks, quotes, and newlines
        let escaped_css = form.css
            .replace("\\", "\\\\")
            .replace("`", "\\`")
            .replace("\"", "\\\"")
            .replace("\n", "\\n")
            .replace("\r", "");
        
        format!(r###"
var touchpointFormOptions{uuid} = {{
    'formId': "{uuid}",
    'modalButtonText': "{button_text}",
    'elementSelector': "{selector}",
    'css': "{css}",
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
    }},
    'htmlFormBody': function() {{
        return `{html_body}`;
    }},
    'htmlFormBodyNoModal': function() {{
        return `{html_body_no_modal}`;
    }}
}};
"###,
            uuid = form.short_uuid,
            button_text = form.modal_button_text,
            selector = form.element_selector,
            css = escaped_css,
            delivery_method = form.delivery_method,
            load_css = form.load_css,
            success_heading = form.success_text_heading,
            success_text = form.success_text,
            suppress_ui = form.suppress_ui,
            suppress_submit = form.suppress_submit_button,
            verify_csrf = form.verify_csrf,
            question_params = question_params,
            html_body = html_body,
            html_body_no_modal = html_body_no_modal
        )
    }

    fn render_form_initialization(&self, form: &FormData) -> String {
        format!(r###"
window.touchpointForm{uuid} = new FBAform(document, window);
window.touchpointForm{uuid}.init(touchpointFormOptions{uuid});
"###,
            uuid = form.short_uuid
        )
    }

    fn render_uswds_bundle(&self) -> String {
        // Include the pre-built USWDS bundle at compile time
        include_str!("../widget-uswds-bundle.js").to_string()
    }

    fn render_uswds_initialization(&self, form: &FormData) -> String {
        format!(r###"

// Initialize any USWDS components used in this form
(function () {{
	try {{
		if (typeof fbaUswds === 'undefined') {{
			console.error("Touchpoints Error: fbaUswds is not defined");
			return;
		}}

		const formId = "touchpoints-form-{uuid}";
		const fbaFormElement = document.querySelector(`#${{formId}}`);
		if (fbaFormElement) {{
			if (fbaUswds.ComboBox) fbaUswds.ComboBox.on(fbaFormElement);
			if (fbaUswds.DatePicker) fbaUswds.DatePicker.on(fbaFormElement);
		}}
		const modalId = "fba-modal-{uuid}";
		const fbaModalElement = document.querySelector(`#${{modalId}}`);
		if (fbaModalElement) {{
			if (fbaUswds.Modal) fbaUswds.Modal.on(fbaModalElement);
		}}
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
		// Ensure the custom button is also initialized if it exists (for 'custom-button-modal' delivery method)
		const customButtonEl = document.getElementById('{element_selector}');
		if (customButtonEl && ('{delivery_method}' === 'custom-button-modal')) {{
			if (fbaUswds.Modal) {{
				fbaUswds.Modal.on(customButtonEl);
			}} else {{
				console.error("Touchpoints Error: fbaUswds.Modal is not defined");
			}}
		}}
	}} catch (e) {{
		console.error("Touchpoints Error: USWDS initialization failed", e);
	}}
}})();
"###, 
            uuid = form.short_uuid,
            element_selector = form.element_selector,
            delivery_method = form.delivery_method
        )
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

    fn prefix_class(&self, form: &FormData, class_name: &str) -> String {
        if !form.prefix.is_empty() {
            format!("{}-{}", form.prefix, class_name)
        } else {
            class_name.to_string()
        }
    }

    pub fn render_html_body_no_modal(&self, form: &FormData) -> String {
        let content_or_archived = if form.kind != "archived" {
             let logo_and_title = self.render_logo_and_title(form);
             let instructions = if let Some(ref instr) = form.instructions {
                 format!(r#"<div class="fba-instructions" id="fba-form-instructions-{}">{}</div>"#, form.short_uuid, instr)
             } else {
                 String::new()
             };
             
             let required_notice = if form.questions.len() > 1 && form.questions.iter().any(|q| q.is_required) {
                 r#"<p class="required-questions-notice"><small>Fields marked with an asterisk (*) are required.</small></p>"#.to_string()
             } else {
                 String::new()
             };
             
             let flash = self.render_flash(form);
             let custom_form = self.render_custom_form(form);
             
             format!("{}{}{}{}{}", logo_and_title, instructions, required_notice, flash, custom_form)
        } else {
            self.render_archived_form(form)
        };

        format!(
            r#"<div class="touchpoints-form-wrapper {}" id="touchpoints-form-{}" data-touchpoints-form-id="{}"><div class="touchpoints-inner-form-wrapper">{}</div></div>"#,
            form.kind, form.short_uuid, form.short_uuid, content_or_archived
        )
    }

    pub fn render_html_body(&self, form: &FormData) -> String {
        let no_modal = self.render_html_body_no_modal(form);
        let footer = self.render_footer(form);
        let close_button = if form.delivery_method != "inline" {
            let close_class = self.prefix_class(form, "usa-modal__close");
            format!(r#"<button class="{} usa-button fba-modal-close" type="button" aria-label="Close this window" data-close-modal><svg class="usa-icon" aria-hidden="true" focusable="false" role="img"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><path d="M19 6.41 17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg></svg></button>"#, close_class)
        } else {
            String::new()
        };

        let content_class = self.prefix_class(form, "usa-modal__content");
        let main_class = self.prefix_class(form, "usa-modal__main");

        format!(
            r#"<div class="{} fba-modal-dialog"><div><div class="{} padding-bottom-0 padding-top-0">{}</div>{}</div>{}</div>"#,
            content_class, main_class, no_modal, footer, close_button
        )
    }

    fn render_logo_and_title(&self, form: &FormData) -> String {
        let mut html = String::new();
        if let (Some(url), Some(class)) = (&form.logo_url, &form.logo_class) {
             html.push_str(&format!(r#"<div class="margin-bottom-2 text-center"><img src="{}" class="{}" alt="Logo"></div>"#, url, class));
        }
        if let Some(title) = &form.title {
             html.push_str(&format!("<h3>{}</h3>", title));
        }
        html
    }

    fn render_flash(&self, _form: &FormData) -> String {
        r#"
        <div class="fba-alert usa-alert usa-alert--success usa-alert--slim" hidden>
          <div class="usa-alert__body">
            <h3 class="usa-alert__heading"></h3>
            <p class="usa-alert__text"></p>
          </div>
        </div>
        <div class="fba-alert-error usa-alert usa-alert--error usa-alert--slim" hidden>
          <div class="usa-alert__body">
            <h3 class="usa-alert__heading">Error</h3>
            <p class="usa-alert__text"></p>
          </div>
        </div>
        "#.to_string()
    }

    fn render_custom_form(&self, form: &FormData) -> String {
        let mut questions_html = String::new();
        for question in &form.questions {
            questions_html.push_str(&format!(r#"
            <div class="question">
                <label class="usa-label">{}</label>
                <input type="text" class="usa-input" name="{}" value="">
            </div>
            "#, question.question_text.as_deref().unwrap_or(""), question.answer_field));
        }
        
        format!(r##"
        <form action="#" method="post" class="touchpoints-form">
            {}
            <button type="submit" class="usa-button">Submit</button>
        </form>
        "##, questions_html)
    }

    fn render_footer(&self, form: &FormData) -> String {
        if let Some(text) = &form.disclaimer_text {
             format!(r#"<div class="touchpoints-form-disclaimer">{}</div>"#, text)
        } else {
            "".to_string()
        }
    }

    fn render_archived_form(&self, _form: &FormData) -> String {
        "<p>This form has been archived.</p>".to_string()
    }
}
