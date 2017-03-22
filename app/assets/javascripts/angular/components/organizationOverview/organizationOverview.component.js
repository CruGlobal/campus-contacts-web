(function () {
    'use strict';

    var bindings = {
        org: '<',
        loadDetails: '<?'
    };

    angular
        .module('missionhubApp')
        .component('organizationOverview', {
            controller: organizationOverviewController,
            bindings: bindings,
            templateUrl: '/assets/angular/components/organizationOverview/organizationOverview.html'
        });

    function organizationOverviewController (JsonApiDataStore, asyncBindingsService, ministryViewTabs,
                                             organizationOverviewService, organizationService, loggedInPerson, _) {
        var vm = this;
        vm.tabNames = ministryViewTabs;
        vm.adminPrivileges = true;
        vm.cruOrg = false;
        vm.$onInit = preactivate;

        function preactivate () {
            asyncBindingsService.resolveAsyncBindings(vm, _.keys(bindings)).then(function () {
                vm.ready = true;
                activate();
            });
        }

        function activate () {
            _.defaults(vm, {
                loadDetails: true
            });
            if (!vm.loadDetails) {
                // Abort before loading org details
                return;
            }

            organizationOverviewService.loadOrgRelations(vm.org).then(function () {
                // Find all of the groups related to the org
                vm.groups = vm.org.groups;

                // Find all of the surveys related to the org
                vm.surveys = vm.org.surveys;
            });

            // The suborgs, people, and team are loaded by their respective tab components, not this component.
            // However, this component does need to know how many people and team members there are, so set the
            // people and team to a sparse array of the appropriate length.
            organizationOverviewService.getSubOrgCount(vm.org).then(function (subOrgCount) {
                vm.suborgs = new Array(subOrgCount);
            });
            organizationOverviewService.getPersonCount(vm.org).then(function (personCount) {
                vm.people = new Array(personCount);
            });
            organizationOverviewService.getTeamCount(vm.org).then(function (teamMemberCount) {
                vm.team = new Array(teamMemberCount);
            });

            vm.adminPrivileges = loggedInPerson.isAdminAt(vm.org);

            var cruOrgId = '1';
            vm.cruOrg = organizationService.getOrgHierarchyIds(vm.org)[0] === cruOrgId;
        }
    }
})();
