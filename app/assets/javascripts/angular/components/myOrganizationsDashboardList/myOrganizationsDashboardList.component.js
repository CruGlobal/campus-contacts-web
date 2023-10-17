import template from './myOrganizationsDashboardList.html';

angular.module('campusContactsApp').component('myOrganizationsDashboardList', {
  template,
  bindings: {
    rootOrgs: '<',
  },
  controller: /* @ngInject */ function (userPreferencesService, $scope) {
    const deregisterEditOrganizationsEvent = $scope.$on('editOrganizations', (_, value) => {
      this.editOrganizations = value;
    });

    const vm = this;

    this.$onDestroy = () => {
      deregisterEditOrganizationsEvent();
    };

    vm.sortableOptions = {
      handle: '.sort-orgs-handle',
      ghostClass: 'o-40',
      forceFallback: true, // Needed to make sticky header and scrollSensitivity work
      scrollSensitivity: 100,
      onEnd: () => userPreferencesService.organizationOrderChange(vm.rootOrgs),
    };
  },
});
