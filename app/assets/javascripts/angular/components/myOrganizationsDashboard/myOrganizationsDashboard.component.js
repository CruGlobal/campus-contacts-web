(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('myOrganizationsDashboard', {
            bindings: {
                editMode: '<'
            },
            templateUrl: '/assets/angular/components/myOrganizationsDashboard/myOrganizationsDashboard.html'
        });
})();
