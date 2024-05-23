/**
 * This file is to be used with the USWDS compiler.
 */

const uswds = require("@uswds/compile");

uswds.settings.version = 3;

uswds.paths.dist.js = './app/assets/javascripts';
uswds.paths.dist.css = './app/assets/stylesheets';
uswds.paths.dist.fonts = './public/fonts';
uswds.paths.dist.img = './public/img';
uswds.paths.dist.theme = './uswds';

exports.copyJS = uswds.copyJS;
exports.compileSass = uswds.compileSass;
exports.copyFonts = uswds.copyFonts;
exports.copyImages = uswds.copyImages;
exports.compileIcons = uswds.compileIcons;
exports.updateUswds = uswds.updateUswds;