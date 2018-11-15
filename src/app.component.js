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
    $http,
) {
    let deregisterEditOrganizationsEvent;

    this.editOrganizations = false;
    this.getPeriod = periodService.getPeriod;
    this.loggedInPerson = loggedInPerson;

    this.$onInit = () => {
        this.year = new Date();

        deregisterEditOrganizationsEvent = $rootScope.$on(
            'editOrganizations',
            (event, value) => {
                this.editOrganizations = value;
            },
        );
    };

    this.$onDestroy = () => deregisterEditOrganizationsEvent();
}
