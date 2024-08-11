module.exports = (opts = {}) => {
  const prefix = opts.prefix || '';
  return {
    postcssPlugin: 'postcss-custom-prefix',
    Rule(rule) {
      rule.selectors = rule.selectors.map(selector => {
        return `${prefix} ${selector}`;
      });
    }
  };
};

module.exports.postcss = true;