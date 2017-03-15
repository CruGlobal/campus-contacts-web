(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('organizationOverviewSuborgs', {
            controller: organizationOverviewSuborgsController,
            require: {
                organizationOverview: '^organizationOverview'
            },
            templateUrl: '/assets/angular/components/organizationOverviewSuborgs/organizationOverviewSuborgs.html'
        });

    function organizationOverviewSuborgsController ($scope, $log, reportsService, periodService, _,
                                                    ProgressiveListLoader, organizationOverviewSuborgsService) {
        var vm = this;
        vm.loadedAll = false;
        vm.subOrgs = [];
        vm.loadSubOrgsPage = loadSubOrgsPage;

        var listLoader = new ProgressiveListLoader('organization');

        function loadSubOrgsPage () {
            if (vm.busy) {
                return;
            }
            vm.busy = true;

            return organizationOverviewSuborgsService.loadOrgSubOrgs(vm.organizationOverview.org, listLoader)
                .then(function (resp) {
                    vm.subOrgs = resp.list;
                    vm.loadedAll = resp.loadedAll;
                    loadReports();
                })
                .finally(function () {
                    vm.busy = false;
                });
        }

        vm.$onInit = activate;

        function activate () {
            periodService.subscribe($scope, loadReports);
        }

        function loadReports () {
            var organizationIds = _.map(vm.subOrgs, 'id');
            reportsService.loadOrganizationReports(organizationIds)
                .catch(function (error) {
                    $log.error('Error loading organization reports', error);
                });
        }
    }
})();
