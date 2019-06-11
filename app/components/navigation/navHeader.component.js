import template from './navHeader.html';
import './navHeader.scss';
import './navSearch.component';

angular.module('missionhubApp').component('navHeader', {
    controller: navHeaderController,
    template: template,
    bindings: {
        hideMenuLinks: '<',
    },
});

function navHeaderController(
    state,
    loggedInPerson,
    envService,
    authenticationService,
) {
    this.loggedInPerson = loggedInPerson;
    this.state = state;

    this.logout = () => {
        authenticationService.destroyTheKeyAccess();
    };
}
