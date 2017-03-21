(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('organizationBreadcrumbs', {
            controller: organizationBreadcrumbsController,
            templateUrl: '/assets/angular/components/organizationBreadcrumbs/organizationBreadcrumbs.html'
        });

    function organizationBreadcrumbsController ($transitions, $uiRouter, JsonApiDataStore, organizationService) {
        var vm = this;
        vm.orgHierarchy = null;

        vm.$onInit = activate;

        function activate () {
            var params = $uiRouter.globals.params;
            updateOrganization(params.orgId);

            $transitions.onSuccess({ to: 'app.ministries.**' }, function (transition) {
                updateOrganization(transition.params('to').orgId);
            });
        }

        function updateOrganization (orgId) {
            var org = JsonApiDataStore.store.find('organization', orgId);
            vm.orgHierarchy = organizationService.getOrgHierarchy(org);
        }
    }
})();
