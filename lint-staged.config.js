//
// lint-staged.config.js
//

const path = require('path');

/** @type {import("lint-staged").configObject} */
const config = {
  // [JSON]
  '**/*.json': (filenames) => filenames.map((filename) => `npm run prettier:lint-staged '${filename}'`),
  // [YAML]
  '**/*.{yaml,yml}': (filenames) => filenames.map((filename) => `npm run prettier:lint-staged '${filename}'`),
  // [Markdown]
  '**/*.{md,mdx}': (filenames) => filenames.map((filename) => `npm run prettier:lint-staged '${filename}'`),

  // Uncomment if needed
  // [JS/TS/Vue]
  // '**/*.{js,jsx,ts,tsx,vue}': (filenames) => filenames.map((filename) => `npm run eslint:lint-staged '${filename}'`),
  // [CSS/SASS/SCSS]
  // '**/*.{sass,scss,css}': (filenames) => filenames.map((filename) => `npm run stylelint:lint-staged '${filename}'`),
  // [Dart]
  //'**/*.dart': (filenames) => filenames.map((filename) => `npm run format:dart:lint-staged '${filename}'`),
  // [Dart]
  //'**/*.dart': (filenames) => filenames.map((filename) => `npm run dartlint:lint-staged '${filename}'`),
  // [Terraform]
  '**/*.tf': (filenames) => {
    const formatter = filenames.map((filename) => `terraform fmt '${filename}'`);
    const directories = filenames.map((filename) => path.dirname(filename));
    const uniqueDirectories = [...new Set(directories)];
    const tflintFile = path.resolve('./infra/.tflint.hcl')
    const linter = uniqueDirectories.map((dir) => `tflint --config="${tflintFile}" --chdir=${dir}`)
    return formatter.concat(linter);
  },
}
module.exports = config
