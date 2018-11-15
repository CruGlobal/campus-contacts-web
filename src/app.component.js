import template from './app.html';
import './components/navigation/navHeader.component';
import './app.scss';

angular.module('missionhubApp').component('app', {
    controller: appController,
    template: template,
    transclude: {
        legacyMenu: '?legacyMenu',
    },
});

function appController(
    loggedInPerson,
    periodService,
    $rootScope,
    state,
    sessionStorageService,
    $timeout,
) {
    let deregisterEditOrganizationsEvent;

    this.editOrganizations = false;
    this.getPeriod = periodService.getPeriod;
    this.loggedInPerson = loggedInPerson;
    this.currentOrganization = state.currentOrganization;

    this.$onInit = () => {
        this.year = new Date();

        $rootScope.$on('state:changed', (event, data) => {
            this.currentOrganization = data.currentOrganization;
        });

        deregisterEditOrganizationsEvent = $rootScope.$on(
            'editOrganizations',
            (event, value) => {
                this.editOrganizations = value;
            },
        );
    };

    this.$onDestroy = () => deregisterEditOrganizationsEvent();
}
