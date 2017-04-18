(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('organizationBreadcrumbs', {
            controller: organizationBreadcrumbsController,
            templateUrl: /* @ngInject */ function (templateUrl) {
                return templateUrl('organizationBreadcrumbs');
            }
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
            organizationService.getOrgHierarchy(org).then(function (hierarchy) {
                vm.orgHierarchy = hierarchy;
            });
        }
    }
})();
