(function () {
    'use strict';

    var contactTabs = ['profile', 'history', 'assigned', 'activity'];
    angular.module('missionhubApp')
        .constant('contactTabs', contactTabs)
        .constant('contactFirstTab', contactTabs[0]);
})();
