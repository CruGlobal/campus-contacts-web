import template from './accordion.html';
import './accordion.scss';

angular.module('campusContactsApp').component('accordion', {
  controller: accordionController,
  bindings: {
    collapsed: '=?',
    collapsible: '=?',
    accordionDisabled: '<',
  },
  template,
  transclude: {
    header: 'accordionHeader',
    content: 'accordionContent',
  },
});

function accordionController(_) {
  const vm = this;

  vm.toggleVisibility = toggleVisibility;

  _.defaults(vm, {
    collapsed: true,
    collapsible: true,
  });

  function toggleVisibility() {
    vm.collapsed = !vm.collapsed;
  }
}
