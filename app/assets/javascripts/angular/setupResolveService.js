(function () {
    'use strict';

    // ui-router's resolveService looks for ui-core module on $window['@uirouter/core'], which it does not populate for
    // some reason, so we have to do that manually
    window['@uirouter/core'] = window['@uirouter/angularjs'].core; // eslint-disable-line angular/window-service
})();
