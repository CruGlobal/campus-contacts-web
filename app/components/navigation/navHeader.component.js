import searchIcon from '../../assets/images/icons/searchIcon.svg';
import campusContactsLogo from '../../assets/images/favicon.svg';

import template from './navHeader.html';
import './navHeader.scss';
import './navSearch.component';

angular.module('campusContactsApp').component('navHeader', {
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
    this.searchIcon = searchIcon;
    this.campusContactsLogo = campusContactsLogo;

    this.logout = () => {
        authenticationService.destroyTheKeyAccess();
    };

    this.toggleSearchBar = () => (this.showSearchBar = !this.showSearchBar);
}
