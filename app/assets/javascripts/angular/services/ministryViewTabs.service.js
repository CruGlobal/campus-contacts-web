(function () {
    'use strict';

    var ministryViewTabs = ['suborgs', 'team', 'groups', 'contacts', 'surveys'];
    angular.module('missionhubApp')
        .constant('ministryViewTabs', ministryViewTabs)
        .constant('ministryViewDefaultTab', ministryViewTabs[0]);
})();
