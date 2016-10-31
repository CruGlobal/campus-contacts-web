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

    function organizationOverviewSuborgsController ($scope, $log, reportsService, periodService, _) {
        var vm = this;

        vm.$onInit = activate;

        function activate () {
            loadReports();
            periodService.subscribe($scope, loadReports);
        }

        function loadReports () {
            var organizationIds = _.map(vm.organizationOverview.suborgs, 'id');
            reportsService.loadOrganizationReports(organizationIds)
                .catch(function (error) {
                    $log.error('Error loading organization reports', error);
                });
        }
    }
})();
