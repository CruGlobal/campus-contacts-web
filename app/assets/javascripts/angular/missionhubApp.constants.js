import _ from 'lodash';
import moment from 'moment';

/* eslint angular/window-service: "off" */

angular
    .module('missionhubApp')
    .constant('_', _)
    .constant('moment', moment)
    .constant('I18n', window.I18n || { t: () => '' })
    .constant('confirm', window.confirm)
    .constant('jQuery', window.jQuery)
    .constant('nativeLocation', window.location)
    .constant('p2cOrgId', '8411')
    .constant(
        'spaPage',
        window.location.pathname === '/' ||
            /^\/d(\/.*)?$/.test(window.location.pathname),
    )
    .constant('rollbarAccessToken', 'e749b290a241465b9e70c9cf93124721');
