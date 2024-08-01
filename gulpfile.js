/**
 * Gulp tasks to build USWDS assets.
 */
const { src, dest, parallel } = require("gulp");
const browserify = require("browserify");
const source = require("vinyl-source-stream");
const rename = require("gulp-rename");
const sass = require("gulp-sass")(require("sass-embedded"));
const postcss = require("gulp-postcss");
const discardComments = require("postcss-discard-comments");
const autoprefixer = require("autoprefixer");
const header = require("gulp-header");
const replace = require('gulp-replace');
const customPrefix = require('./postcss-custom-touchpoints-prefix');

const uswds = require("@uswds/compile");

uswds.settings.version = 3;

uswds.paths.dist.js = './app/assets/javascripts';
uswds.paths.dist.css = './app/assets/stylesheets';
uswds.paths.dist.fonts = './public/fonts';
uswds.paths.dist.img = './public/img';
uswds.paths.dist.theme = './uswds';

// Tasks to build USWDS assets for the Touchpoints app.
// These tasks use the USWDS compiler.
exports.copyJS = uswds.copyJS;
exports.compileSass = uswds.compileSass;
exports.copyFonts = uswds.copyFonts;
exports.copyImages = uswds.copyImages;
exports.compileIcons = uswds.compileIcons;
exports.updateUswds = uswds.updateUswds;

// Tasks to build USWDS assets for the embedded survey widget.
// These tasks do not use the USWDS compiler.
exports.bundleWidgetJS = bundleWidgetJS;
exports.compileWidgetSass = compileWidgetSass;
exports.buildWidgetAssets = parallel(bundleWidgetJS, compileWidgetSass);

embeddedWidgetPath = './app/views/components/widget';

async function bundleWidgetJS() {
  return browserify("uswds/widget-uswds.js", {
    paths: ['./node_modules'],
    debug: true
  })
    .transform("babelify", {
      global: true,
      presets: ["@babel/preset-env"],
    })
    .transform("aliasify", {
      aliases: {
        '../../uswds-core/src/js/config': './uswds/uswds-config.js'
      },
      verbose: true,
      global: true
    })
    .bundle()
    .pipe(source('_widget-uswds.js.erb'))
    .pipe(header("/* This file was generated by the gulp task 'bundleWidgetJS'. */\n\n"))
    .pipe(dest(embeddedWidgetPath));
}

async function compileWidgetSass() {
  const pluginsProcess = [
    discardComments(),
    customPrefix({
      prefix: ".fba-modal-dialog"
    }),
    autoprefixer()
  ];

  return src("uswds/widget-uswds-styles.scss")
    .pipe(
      sass({
        includePaths: [
          "node_modules/@uswds/uswds/packages",
        ],
        outputStyle: "expanded",
      }).on("error", function handleError(error) {
        console.log(error);
        this.emit("end");
      })
    )
    .pipe(postcss(pluginsProcess))
    .pipe(replace('../', '<%= root_url %>')) // Update the Rails asset ../img/ references
    .pipe(header("/* This file was generated by the gulp task 'compileWidgetSass'. */\n\n"))
    .pipe(rename({ prefix: "_", extname: ".css.erb" }))
    .pipe(dest(embeddedWidgetPath));
}
