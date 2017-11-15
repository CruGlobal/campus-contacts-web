import template from './nav.html';

angular
    .module('missionhubApp')
    .component('nav', {
        controller: navController,
        template: template
    });

function navController (state, loggedInPerson) {
    var vm = this;

    vm.state = state;
    vm.loggedInPerson = loggedInPerson;
}
