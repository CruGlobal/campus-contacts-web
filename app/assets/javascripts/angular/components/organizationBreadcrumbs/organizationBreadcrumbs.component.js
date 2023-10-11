import template from './organizationBreadcrumbs.html';
import './organizationBreadcrumbs.scss';

angular.module('campusContactsApp').component('organizationBreadcrumbs', {
  controller: organizationBreadcrumbsController,
  template,
  bindings: {
    orgId: '<',
  },
});

function organizationBreadcrumbsController($transitions, $uiRouter, JsonApiDataStore, organizationService) {
  const vm = this;
  vm.orgHierarchy = null;

  vm.$onInit = activate;

  function activate() {
    if (vm.orgId) {
      organizationService.loadOrgsById([vm.orgId], 'error.messages.organization.load_ancestry').then(function () {
        updateOrganization(vm.orgId);
      });
    } else {
      updateOrganization($uiRouter.globals.params.orgId);
      subscribe();
    }
  }

  function subscribe() {
    $transitions.onSuccess({ to: 'app.ministries.**' }, function (transition) {
      updateOrganization(transition.params('to').orgId);
    });
  }

  function updateOrganization(orgId) {
    const org = JsonApiDataStore.store.find('organization', orgId);
    organizationService.getOrgHierarchy(org).then(function (hierarchy) {
      vm.orgHierarchy = hierarchy;
    });
  }
}
