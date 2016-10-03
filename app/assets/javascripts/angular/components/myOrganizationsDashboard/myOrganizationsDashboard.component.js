(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('myOrganizationsDashboard', {
            controller: myOrganizationsDashboardController,
            bindings: {
                editMode: '<'
            },
            templateUrl: '/assets/angular/components/myOrganizationsDashboard/myOrganizationsDashboard.html'
        });

    function myOrganizationsDashboardController (JsonApiDataStore, periodService,
                                                 myContactsDashboardService, _) {
        var vm = this;
        vm.numberOfOrgsToShow = 1000;

        vm.$onInit = activate;

        function activate () {
            loadReports();
        }

        function loadReports () {
            var organization_ids = _.map(JsonApiDataStore.store.findAll('organization'), 'id').join(',');
            myContactsDashboardService.loadOrganizationReports({
                period: periodService.getPeriod(),
                organization_ids: organization_ids
            });
        }
    }
})();
