(function () {
    'use strict';

    var ministryViewTabs = ['suborgs', 'team', 'groups', 'contacts', 'surveys'];
    angular.module('missionhubApp')
        .constant('ministryViewTabs', ministryViewTabs)
        .constant('ministryViewFirstTab', ministryViewTabs[0]);
})();
