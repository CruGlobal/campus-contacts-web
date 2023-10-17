import template from './organizationOverviewLabels.html';
import './organizationOverviewLabels.scss';

angular.module('campusContactsApp').component('organizationOverviewLabels', {
  controller: organizationOverviewLabelsController,
  require: {
    organizationOverview: '^',
  },
  template,
});

function organizationOverviewLabelsController($uibModal, _) {
  const vm = this;
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
