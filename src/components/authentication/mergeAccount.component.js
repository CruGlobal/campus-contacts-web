import template from './mergeAccount.html';

angular.module('missionhubApp').component('mergeAccount', {
    controller: mergeAccountController,
    template: template,
    bindings: {
        rememberCode: '<',
        userId: '<',
        orgId: '<',
        loggedInUser: '<',
    },
});

function mergeAccountController(
    authenticationService,
    $state,
    httpProxy,
    $scope,
    sessionStorageService,
) {
    this.inviteAccount = '';

    this.$onInit = async () => {
        if (!authenticationService.isTokenValid()) $state.go('app.signIn');

        const { data } = await httpProxy.get(
            `/user_remember_tokens/${this.rememberCode}`,
            {},
            {
                errorMessage: 'error.messages.inviteLink.loadRemeberToken',
            },
        );

        this.inviteAccount = `${data.full_name} <${data.username}>`;
        $scope.$apply();
    };

    this.cancelMerge = () => {
        authenticationService.removeAccess();
    };

    this.mergeAccount = async () => {
        try {
            await httpProxy.post(
                `/user_remember_tokens/${this.rememberCode}/merge`,
                {
                    errorMessage: 'error.messages.inviteLink.mergeAccount',
                },
            );

            sessionStorageService.clear('inviteState');
        } catch (e) {}
    };
}
