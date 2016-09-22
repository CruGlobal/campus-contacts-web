(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('organizationOverview', {
            controller: organizationOverviewController,
            bindings: {
                onNavigation: '<',
                org: '<',
                period: '<'
            },
            templateUrl: '/assets/angular/components/organizationOverview/organizationOverview.html'
        });

    function organizationOverviewController (JsonApiDataStore,
                                             myContactsDashboardService, myOrganizationsDashboardService, _) {
        var vm = this;

        vm.tabs = ['suborgs', 'admins', 'groups', 'contacts', 'surveys'];
        vm.tab = vm.tabs[0];
        vm.$onInit = activate;

        function activate () {
            loadSuborgs().then(function () {
                // Find all of the organizations with org as its parent
                vm.suborgs = _.filter(JsonApiDataStore.store.findAll('organization'), {
                    ancestry: vm.org.ancestry + '/' + vm.org.id
                });
            });

            loadContacts().then(function () {
                vm.contacts = JsonApiDataStore.store.findAll('person').filter(function (person) {
                    // Include the person if they are part of this organization
                    return _.filter(person.organizational_permissions, {
                        organization_id: vm.org.id
                    }).length > 0;
                });
            });

            loadAdmins().then(function () {
                vm.admins = JsonApiDataStore.store.findAll('person').filter(function (person) {
                    // Include the person if they are an admin of this organization
                    return _.filter(person.organizational_permissions, {
                        organization_id: vm.org.id,
                        permission_id: 1 // 1 is the admin permission
                    }).length > 0
                });
            });

            loadGroups().then(function () {
                vm.groups = _.filter(JsonApiDataStore.store.findAll('group'), ['organization.id', vm.org.id]);
            });

            loadSurveys().then(function () {
                vm.surveys = vm.org.surveys;
            });

            vm.surveys = [];
        }

        // Load all of the suborgs belonging to the organization
        function loadSuborgs () {
            return myContactsDashboardService.loadOrganizations({
                'filters[parent_ids]': vm.org.id
            });
        }

        // Load all of the admins belonging to the organization
        function loadAdmins () {
            return myContactsDashboardService.loadPeople({
                include: 'organizational_permissions.organization',
                'filters[permissions]': 'admin',
                organization_id: vm.org.id
            });
        }

        // Load all of the contacts belonging to the organization
        function loadContacts () {
            return myContactsDashboardService.loadPeople({
                include: 'organizational_permissions.organization',
                organization_id: vm.org.id
            });
        }

        // Load all of the groups belonging to the organization
        function loadGroups () {
            return myOrganizationsDashboardService.loadGroups({
                'filters[organization_ids]': vm.org.id
            });
        }

        // Load all of the surveys belonging to the organization
        function loadSurveys () {
            return myOrganizationsDashboardService.loadSurveys(vm.org.id);
        }
    }
})();
