(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('organizationOverviewAdmins', {
            controller: organizationOverviewAdminsController,
            bindings: {
                org: '<'
            },
            templateUrl: '/assets/angular/components/organizationOverviewAdmins/organizationOverviewAdmins.html'
        });

    function organizationOverviewAdminsController (organizationOverviewAdminsService) {
        var vm = this;
        vm.admins = null;
        vm.loadAdminPage = loadAdminPage;

        function loadAdminPage (page) {
            return organizationOverviewAdminsService.loadOrgAdmins(vm.org, page);
        }
    }
})();
