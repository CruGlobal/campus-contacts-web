import './main.js';

/* global require */
// require all spec files
const testsContext = require.context('../', true, /\.\/.*\.spec\.js$/);
testsContext.keys().forEach(testsContext);
