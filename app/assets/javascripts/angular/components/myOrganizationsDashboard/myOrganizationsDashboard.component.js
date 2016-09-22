(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('myOrganizationsDashboard', {
            controller: myOrganizationsDashboardController,
            bindings: {
                editMode: '<',
                period: '<'
            },
            templateUrl: '/assets/angular/components/myOrganizationsDashboard/myOrganizationsDashboard.html'
        });

    function myOrganizationsDashboardController (JsonApiDataStore, loggedInPerson, orgSorter,
                                                 myContactsDashboardService, myOrganizationsDashboardService, _) {
        var vm = this;
        vm.currentOrg = null;
        vm.orgHierarchy = [];
        vm.numberOfOrgsToShow = 1000;

        vm.toggleOrgVisibility = myContactsDashboardService.toggleOrganizationVisibility;
        vm.onNavigation = onNavigation;
        vm.navigateToChild = navigateToChild;
        vm.navigateToParent = navigateToParent;

        vm.$onInit = activate;

        function activate () {
            navigateToChild(null);

            loadRootOrganizations().then(function () {
                // Find all of the organizations that the user is an admin of
                vm.rootOrgs = orgSorter.sort(_(JsonApiDataStore.store.findAll('organizational_permission'))
                    .filter({
                        person_id: loggedInPerson.person.id,
                        permission_id: 1 // 1 is the admin permission
                    })
                    .map('organization')
                    .value());
            });

            loadReports();
        }

        // Called whenever the organization-overview component requests navigation to a new component
        // parentOrg is the org represented by the organization-overview component, and
        // childOrg is optionally the sub-org to navigate to
        function onNavigation (parentOrg, childOrg) {
            if (parentOrg !== vm.currentOrg) {
                // Make sure that the parentOrg is in the ancestry list
                // This will happen when the sub-org of a root org is navigated to
                vm.navigateToChild(parentOrg);
            }
            if (childOrg) {
                vm.navigateToChild(childOrg);
            }
        }

        // Navigate to a child of the current org
        function navigateToChild (child) {
            vm.orgHierarchy.push(child);
            changeRootOrganization(child);
        }

        // Navigate to a parent of the current org
        function navigateToParent (parent) {
            var index = vm.orgHierarchy.indexOf(parent);
            if (index !== -1) {
                vm.orgHierarchy = vm.orgHierarchy.slice(0, index + 1);
            }
            changeRootOrganization(parent);
        }

        function changeRootOrganization (newOrg) {
            vm.currentOrg = newOrg;
        }

        function loadReports () {
            var organization_ids = _.map(JsonApiDataStore.store.findAll('organization'), 'id').join(',');
            myContactsDashboardService.loadOrganizationReports({
                period: vm.period,
                organization_ids: organization_ids
            });
        }

        function loadRootOrganizations () {
            return myContactsDashboardService.loadOrganizations({});
        }
    }
})();
