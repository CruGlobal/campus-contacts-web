import template from './login.html';
import './login.scss';

angular.module('missionhubApp').component('login', {
    controller: loginController,
    template: template,
    bindings: {
        accessToken: '<',
    },
});

function loginController(authenticationService, envService, $state) {
    this.$onInit = async () => {
        this.theKeyUrl = authenticationService.theKeyloginUrl;
        this.url = envService.read('railsUrl');

        if (authenticationService.isTokenValid()) {
            $state.go('app.people');
        }

        if (this.accessToken) {
            await authenticationService.authorizeAccess(this.accessToken);
        }
    };
}
