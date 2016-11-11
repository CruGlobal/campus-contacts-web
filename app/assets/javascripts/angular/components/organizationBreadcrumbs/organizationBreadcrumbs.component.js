(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('organizationBreadcrumbs', {
            controller: organizationBreadcrumbsController,
            templateUrl: '/assets/angular/components/organizationBreadcrumbs/organizationBreadcrumbs.html'
        });

    function organizationBreadcrumbsController ($transitions, $stateParams, organizationService) {
        var vm = this;
        vm.orgHierarchy = null;

        vm.$onInit = activate;

        function activate () {
            updateOrganization($stateParams.orgId);

            $transitions.onSuccess({ to: 'app.ministries.**' }, function (transition) {
                updateOrganization(transition.params('to').orgId);
            });
        }

        function updateOrganization (orgId) {
            vm.orgHierarchy = organizationService.getOrgHierarchy(orgId || null);
        }
    }
})();
