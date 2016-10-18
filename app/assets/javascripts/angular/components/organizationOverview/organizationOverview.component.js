(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('organizationOverview', {
            controller: organizationOverviewController,
            bindings: {
                org: '<',
                loadDetails: '<?'
            },
            templateUrl: '/assets/angular/components/organizationOverview/organizationOverview.html'
        });

    function organizationOverviewController (JsonApiDataStore, ministryViewTabs, ministryViewFirstTab,
                                             organizationOverviewContactsService, organizationOverviewTeamService,
                                             organizationOverviewService, _) {
        var vm = this;

        _.defaults(vm, {
            loadDetails: true
        });

        vm.tabNames = ministryViewTabs;
        vm.firstTab = ministryViewFirstTab;
        vm.$onInit = activate;

        function activate () {
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

            organizationOverviewService.loadOrgSuborgs(vm.org).then(function () {
                // Find all of the organizations with org as its parent
                vm.suborgs = _.filter(JsonApiDataStore.store.findAll('organization'), {
                    ancestry: vm.org.ancestry + '/' + vm.org.id
                });
            });

            // The contacts and team are loaded by their respective tab components, not this component.
            // However, this component does need to know how many contacts and team members there are, so set the
            // contacts and team to a sparse array of the appropriate length.
            organizationOverviewContactsService.loadOrgContacts(vm.org, { limit: 0, offset: 0 }).then(function (response) {
                vm.contacts = new Array(response.meta.total);
            });

            organizationOverviewTeamService.loadOrgTeam(vm.org, { limit: 0, offset: 0 }).then(function (response) {
                vm.team = new Array(response.meta.total);
            });
        }
    }
})();
