import template from './accordionToggle.html';
import './accordionToggle.scss';

angular.module('campusContactsApp').component('accordionToggle', {
  controller: accordionToggleController,
  require: {
    accordion: '^',
  },
  template,
  transclude: true,
});

function accordionToggleController() {
  const vm = this;

  vm.toggleVisibility = toggleVisibility;

  function toggleVisibility() {
    vm.accordion.collapsed = !vm.accordion.collapsed;
  }
}
