(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('organizationOverviewContacts', {
            controller: organizationOverviewContactsController,
            bindings: {
                org: '<'
            },
            templateUrl: '/assets/angular/components/organizationOverviewContacts/organizationOverviewContacts.html'
        });

    function organizationOverviewContactsController (organizationOverviewContactsService) {
        var vm = this;
        vm.contacts = null;
        vm.loadContactPage = loadContactPage;

        function loadContactPage (page) {
            return organizationOverviewContactsService.loadOrgContacts(vm.org, page);
        }
    }
})();
