(function () {
    'use strict';

    // ui-router's resolveService looks for ui-core module on $window['ui-router-core'], which it does not populate for
    // some reason, so we have to do that manually
    window['ui-router-core'] = window['angular-ui-router'].core; // eslint-disable-line angular/window-service
})();
