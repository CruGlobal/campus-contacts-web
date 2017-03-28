(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('myOrganizationsDashboard', {
            bindings: {
                editMode: '<'
            },
            templateUrl: /* @ngInject */ function (templateUrl) {
                return templateUrl('myOrganizationsDashboard');
            }
        });
})();
