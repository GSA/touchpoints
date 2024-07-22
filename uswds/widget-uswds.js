const modal = require("@uswds/uswds/packages/usa-modal/src/index.js");

const touchpointsModalRoots = document.querySelectorAll(".fba-modal");

// Initialize modal event listeners for each modal Touchpoint widget on the page
touchpointsModalRoots.forEach((element) => modal.on(element));