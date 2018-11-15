import template from './navHeader.html';
import './navHeader.scss';
import './navSearch.component';

angular.module('missionhubApp').component('navHeader', {
    controller: navHeaderController,
    template: template,
});

function navHeaderController(
    state,
    loggedInPerson,
    envService,
    authenticationService,
    $rootScope,
) {
    this.loggedInPerson = loggedInPerson;
    this.state = state;
    this.railsUrl = envService.read('railsUrl');

    this.logout = () => {
        authenticationService.removeAccess();
    };
}
