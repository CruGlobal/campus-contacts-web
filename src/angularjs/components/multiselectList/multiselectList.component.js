multiselectListController.$inject = ['multiselectListService', '_'];
import template from './multiselectList.html';
import './multiselectList.scss';

angular.module('missionhubApp').component('multiselectList', {
  controller: multiselectListController,
  bindings: {
    // list of objects that have an id and name
    options: '=',

    // dictionary with id keys and value of true/false/null
    originalSelection: '=',
    addedOutput: '=',
    removedOutput: '=',
  },
  template: template,
});

function multiselectListController(multiselectListService, _) {
  var vm = this;

  vm.toggle = toggle;
  vm.isSelected = isSelected;
  vm.isUnselected = isUnselected;
  vm.isIndeterminate = isIndeterminate;

  vm.$onInit = activate;

  function activate() {
    fillSelected();

    vm.addedOutput = vm.addedOutput || [];
    vm.removedOutput = vm.removedOutput || [];
  }

  function fillSelected() {
    vm.selected = _.clone(vm.originalSelection);
  }

  function toggle(id) {
    multiselectListService.toggle(id, {
      originalSelection: vm.originalSelection,
      currentSelection: vm.selected,
      addedOutput: vm.addedOutput,
      removedOutput: vm.removedOutput,
    });
  }

  function isSelected(id) {
    return multiselectListService.isSelected(vm.selected, id);
  }

  function isUnselected(id) {
    return multiselectListService.isUnselected(vm.selected, id);
  }

  function isIndeterminate(id) {
    return multiselectListService.isIndeterminate(vm.selected, id);
  }
}
