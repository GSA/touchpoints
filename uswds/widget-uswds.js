const ComboBox = require("@uswds/uswds/packages/usa-combo-box/src/index.js");
const DatePicker = require("@uswds/uswds/packages/usa-date-picker/src/index.js");
const Modal = require("@uswds/uswds/packages/usa-modal/src/index.js");

// Make these components available in the global browser scope so that Touchpoints code can call initialization functions.
window.fbaUswds = {
  ComboBox,
  DatePicker,
  Modal
}
