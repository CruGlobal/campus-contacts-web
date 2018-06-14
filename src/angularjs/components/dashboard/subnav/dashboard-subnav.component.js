DashboardSubnavController.$inject = ['$scope'];
import template from './dashboard-subnav.html';

angular.module('missionhubApp').component('dashboardSubnav', {
  controller: DashboardSubnavController,
  template: template,
});

function DashboardSubnavController($scope) {
  var vm = this;

  vm.editOrganizations = false;

  vm.toggleEditOrganizations = toggleEditOrganizations;

  function toggleEditOrganizations() {
    vm.editOrganizations = !vm.editOrganizations;
    $scope.$emit('editOrganizations', vm.editOrganizations);
  }
}
