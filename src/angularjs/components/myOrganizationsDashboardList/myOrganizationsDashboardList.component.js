import template from './myOrganizationsDashboardList.html';

angular.module('missionhubApp').component('myOrganizationsDashboardList', {
  template: template,
  require: {
    myOrganizationsDashboard: '^',
  },
  bindings: {
    rootOrgs: '<',
  },
  controller: /* @ngInject */ [
    'userPreferencesService',
    function(userPreferencesService) {
      var vm = this;

      vm.sortableOptions = {
        handle: '.sort-orgs-handle',
        stop: function() {
          return userPreferencesService.organizationOrderChange(vm.rootOrgs);
        },
      };
    },
  ],
});
