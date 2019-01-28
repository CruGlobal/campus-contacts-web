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

function appController(periodService, $rootScope, state, analyticsService) {
    let deregisterEditOrganizationsEvent;
    let deregisterStateChangedEvent;
    let deregisterUiStateChangedEvent;

    this.editOrganizations = false;
    this.getPeriod = periodService.getPeriod;
    this.currentOrganization = state.currentOrganization;
    this.hideHeader = false;
    this.hideFooter = false;

    this.$onInit = () => {
        this.year = new Date();

        deregisterStateChangedEvent = $rootScope.$on(
            'state:changed',
            (event, { loggedIn, currentOrganization }) => {
                this.currentOrganization = currentOrganization;

                if (loggedIn) analyticsService.setupAuthenitcatedAnalyticData();
                else analyticsService.clearAuthenticatedData();
            },
        );

        deregisterUiStateChangedEvent = $rootScope.$on(
            'uiState:changed',
            (event, { header, footer }) => {
                this.hideHeader = header === 'hidden';
                this.hideFooter = footer === 'hidden';
            },
        );

        deregisterEditOrganizationsEvent = $rootScope.$on(
            'editOrganizations',
            (event, value) => {
                this.editOrganizations = value;
            },
        );
    };

    this.$onDestroy = () => {
        deregisterEditOrganizationsEvent();
        deregisterStateChangedEvent();
        deregisterUiStateChangedEvent();
    };
}
