organizationOverviewLabelsController.$inject = ['$uibModal', '_'];
import template from './organizationOverviewLabels.html';
import './organizationOverviewLabels.scss';

angular.module('missionhubApp').component('organizationOverviewLabels', {
  controller: organizationOverviewLabelsController,
  require: {
    organizationOverview: '^',
  },
  template: template,
});

function organizationOverviewLabelsController($uibModal, _) {
  var vm = this;
  vm.addLabel = addLabel;

  function addLabel() {
    $uibModal.open({
      component: 'editLabel',
      resolve: {
        organizationId: _.constant(vm.organizationOverview.org.id),
      },
      windowClass: 'pivot_theme',
      size: 'sm',
    });
  }
}
