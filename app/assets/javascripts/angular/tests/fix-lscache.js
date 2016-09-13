'use strict';

// Under Karma, module is defined, so lscache defines its export as a CommonJS module on module.exports instead of
// on the window object. This line puts lscache back on the window object.
if (!window.lscache) {
    window.lscache = window.module.exports;
}
