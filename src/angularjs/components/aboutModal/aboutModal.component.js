import template from './aboutModal.html';
import './aboutModal.scss';

angular.module('missionhubApp').component('aboutModal', {
  controller: aboutModalController,
  template: template,
  bindings: {
    resolve: '<',
    close: '&',
    dismiss: '&',
  },
});

function aboutModalController() {
  const vm = this;

  vm.year = new Date().getFullYear();

  vm.$onInit = activate;

  function activate() {}
}
