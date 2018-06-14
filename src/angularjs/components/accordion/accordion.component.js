accordionController.$inject = ['_'];
import template from './accordion.html';
import './accordion.scss';

angular.module('missionhubApp').component('accordion', {
  controller: accordionController,
  bindings: {
    collapsed: '=?',
    collapsible: '=?',
    accordionDisabled: '<',
  },
  template: template,
  transclude: {
    header: 'accordionHeader',
    content: 'accordionContent',
  },
});

function accordionController(_) {
  var vm = this;

  vm.toggleVisibility = toggleVisibility;

  _.defaults(vm, {
    collapsed: true,
    collapsible: true,
  });

  function toggleVisibility() {
    vm.collapsed = !vm.collapsed;
  }
}
