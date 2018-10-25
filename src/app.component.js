import template from './app.html';

angular.module('missionhubApp').component('app', {
    controller: appController,
    template: template,
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

    this.$onInit = async () => {
        this.year = new Date();
        setAuthorizationAndState();
        deregisterEditOrganizationsEvent = $rootScope.$on(
            'editOrganizations',
            function(event, value) {
                this.editOrganizations = value;
            },
        );

        const { user } = await loggedInPerson.loadOnce();

        if (user.beta_mode === null) {
            $uibModal.open({
                component: 'newWelcomeModal',
                resolve: {},
                windowClass: 'pivot_theme',
                size: 'sm',
            });
        }
    };

    this.$onDestroy = () => deregisterEditOrganizationsEvent();
}
