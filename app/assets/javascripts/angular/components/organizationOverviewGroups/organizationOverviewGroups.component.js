import template from './organizationOverviewGroups.html';
import './organizationOverviewGroups.scss';

angular.module('campusContactsApp').component('organizationOverviewGroups', {
  controller: organizationOverviewGroupsController,
  require: {
    organizationOverview: '^',
  },
  template,
});

function organizationOverviewGroupsController($uibModal, groupsService, _) {
  const vm = this;
  vm.addGroup = addGroup;
  vm.$onInit = activate;

  function activate() {
    // Load the groups and leaders
    groupsService.loadLeaders(vm.organizationOverview.org);
  }

  function addGroup() {
    $uibModal.open({
      component: 'editGroup',
      resolve: {
        organizationId: _.constant(vm.organizationOverview.org.id),
      },
      windowClass: 'pivot_theme',
      size: 'md',
    });
  }
}
