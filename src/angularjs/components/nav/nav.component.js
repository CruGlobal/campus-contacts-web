import template from './nav.html';

angular.module('missionhubApp').component('nav', {
  controller: navController,
  template: template,
});

function navController(state, loggedInPerson, $timeout) {
  var vm = this;

  vm.state = state;
  $timeout(() => {
    vm.loggedInPerson = loggedInPerson;
  });
}
