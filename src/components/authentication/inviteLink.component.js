import template from './inviteLink.html';

angular.module('missionhubApp').component('inviteLink', {
    controller: inviteLinkController,
    template: template,
    bindings: {
        rememberCode: '<',
        userId: '<',
    },
});

function inviteLinkController(
    authenticationService,
    $state,
    sessionStorageService,
) {
    this.$onInit = async () => {
        if (!authenticationService.isTokenValid()) {
            const inviteState = {
                rememberCode: this.rememberCode,
                userId: this.userId,
            };
            sessionStorageService.set('inviteState', inviteState);

            $state.go('app.signIn');
        }

        if (authenticationService.isTokenValid()) {
            const token = await httpProxy.get(
                `/user_remember_tokens/${this.rememberCode}`,
                {
                    errorMessage: 'error.messages.surveys.loadQuestions',
                },
            );

            console.log(token);
        }
    };
}
