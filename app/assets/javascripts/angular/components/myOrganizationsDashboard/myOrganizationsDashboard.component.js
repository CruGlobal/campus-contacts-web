(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('myOrganizationsDashboard', {
            templateUrl: /* @ngInject */ function (templateUrl) {
                return templateUrl('myOrganizationsDashboard');
            },
            controller: function ($state) {
                this.$state = $state;
            }
        });
})();
