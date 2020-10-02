import campusContactsLogo from '../../assets/images/favicon.svg';

import template from './signIn.html';
import './signIn.scss';

angular.module('campusContactsApp').component('signIn', {
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
    this.campusContactsLogo = campusContactsLogo;

    this.$onInit = async () => {
        this.theKeyLoginUrl = authenticationService.theKeyLoginUrl;
        this.theKeySignUpUrl = authenticationService.theKeySignUpUrl;

        if (authenticationService.isTokenValid()) {
            authenticationService.postAuthRedirect();
        }

        if (this.accessToken) {
            await authenticationService.authorizeAccess(this.accessToken);
        }

        if (!this.accessToken) this.showLogin = true;

        this.inviteState = sessionStorageService.get('inviteState');
    };
}
