newWelcomeModalController.$inject = ['$rootScope', 'loggedInPerson'];
import template from './newWelcomeModal.html';
import './newWelcomeModal.scss';

angular.module('missionhubApp').component('newWelcomeModal', {
  controller: newWelcomeModalController,
  template: template,
  bindings: {
    dismiss: '&',
  },
});

function newWelcomeModalController($rootScope, loggedInPerson) {
  var vm = this;

  vm.sending = false;

  vm.accept = accept;

  function accept() {
    vm.sending = true;
    loggedInPerson
      .updatePreferences({ beta_mode: true })
      .then(function() {
        $rootScope.legacyNavigation = false;
      })
      .then(vm.dismiss)
      .catch(function() {
        vm.sending = false;
      });
  }
}
