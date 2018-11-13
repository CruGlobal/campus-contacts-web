import template from './app.html';
import './components/navigation/navHeader.component';
import './app.scss';

angular.module('missionhubApp').component('app', {
    controller: appController,
    template: template,
    transclude: {
        legacyMenu: '?legacyMenu',
    },
    bindings: {
        jwtToken: '@',
        access: '<',
        currentOrganization: '<',
        branded: '<',
    },
});

function appController(
    loggedInPerson,
    periodService,
    $uibModal,
    $rootScope,
    state,
    $state,
    $http,
) {
    let deregisterEditOrganizationsEvent;

    this.editOrganizations = false;
    this.getPeriod = periodService.getPeriod;
    this.loggedInPerson = loggedInPerson;

    const setAuthorizationAndState = () => {
        state.branded = this.branded;
        state.hasMissionhubAccess = this.access;
        state.currentOrganization = this.currentOrganization
            ? this.currentOrganization
            : 0;

        if (this.jwtToken) {
            state.v4AccessToken = this.jwtToken;
            $http.defaults.headers.common.Authorization =
                'Bearer ' + this.jwtToken;
        }
    };

    this.$onInit = () => {
        this.year = new Date();
        setAuthorizationAndState();
        deregisterEditOrganizationsEvent = $rootScope.$on(
            'editOrganizations',
            (event, value) => {
                this.editOrganizations = value;
            },
        );
    };

    this.$onDestroy = () => deregisterEditOrganizationsEvent();
}
