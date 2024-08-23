const ComboBox = require("@uswds/uswds/packages/usa-combo-box/src/index.js");
const DatePicker = require("@uswds/uswds/packages/usa-date-picker/src/index.js");
const Modal = require("@uswds/uswds/packages/usa-modal/src/index.js");

// Initialize event listeners
const fbaFormElement = document.querySelector(".touchpoints-form-wrapper");
if (fbaFormElement) {
  ComboBox.on(fbaFormElement); // Initialize all .usa-combo-box elements within the Touchpoints form
  DatePicker.on(fbaFormElement); // Initialize all .usa-date-picker elements within the Touchpoints form
}

Modal.on(); // Initialize all .fba-usa-modal elements within the document
