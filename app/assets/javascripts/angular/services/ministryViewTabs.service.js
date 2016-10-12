(function () {
    'use strict';

    var ministryViewTabs = ['suborgs', 'admins', 'groups', 'contacts', 'surveys'];
    angular.module('missionhubApp')
        .constant('ministryViewTabs', ministryViewTabs)
        .constant('ministryViewFirstTab', ministryViewTabs[0]);
})();
