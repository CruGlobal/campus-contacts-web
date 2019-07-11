import template from './signIn.html';
import './signIn.scss';

angular.module('missionhubApp').component('signIn', {
    controller: signInController,
    template: template,
    bindings: {
        accessToken: '<',
    },
});

function signInController(
    authenticationService,
    envService,
    $state,
    facebookService,
    sessionStorageService,
) {
    this.showLogin = false;
    this.facebookService = facebookService;

    this.$onInit = async () => {
        this.theKeyUrl = authenticationService.theKeyloginUrl;
        this.theKeySignUpUrl = authenticationService.theKeySignUpUrl;

        if (authenticationService.isTokenValid()) {
            $state.go('app.people');
        }

        if (this.accessToken) {
            await authenticationService.authorizeAccess(this.accessToken);
        }

        if (!this.accessToken) this.showLogin = true;

        this.inviteState = sessionStorageService.get('inviteState');
    };
}
