(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('organizationBreadcrumbs', {
            controller: organizationBreadcrumbsController,
            bindings: {
                org: '<'
            },
            templateUrl: '/assets/angular/components/organizationBreadcrumbs/organizationBreadcrumbs.html'
        });

    function organizationBreadcrumbsController (ministryViewFirstTab, organizationBreadcrumbsService) {
        var vm = this;
        vm.firstTab = ministryViewFirstTab;
        vm.orgHierarchy = null;

        vm.$onInit = activate;

        function activate () {
            vm.orgHierarchy = organizationBreadcrumbsService.getOrgHierarchy(vm.org);
        }
    }
})();
