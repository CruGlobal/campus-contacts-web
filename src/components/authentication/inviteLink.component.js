import template from './inviteLink.html';

angular.module('missionhubApp').component('inviteLink', {
    controller: inviteLinkController,
    template: template,
    bindings: {
        rememberCode: '<',
        userId: '<',
        orgId: '<',
    },
});

function inviteLinkController(
    authenticationService,
    $state,
    sessionStorageService,
    httpProxy,
    loggedInPerson,
    $location,
    $scope,
    $sce,
    $filter,
) {
    this.errorWithLink = false;

    const setInviteState = (rememberCode, userId, orgId) => {
        const inviteState = {
            rememberCode: this.rememberCode,
            userId: this.userId,
            orgId: this.orgId,
        };
        sessionStorageService.set('inviteState', inviteState);
        return inviteState;
    };

    this.$onInit = async () => {
        this.expiredText = $sce.trustAsHtml(
            $filter('t')('mergeAccount.inviteLinkExpiredMessage'),
        );

        const inviteState = setInviteState(
            this.rememberCode,
            this.userId,
            this.orgId,
        );

        if (!authenticationService.isTokenValid()) $state.go('app.signIn');

        if (authenticationService.isTokenValid()) {
            try {
                const { data } = await httpProxy.get(
                    `/user_remember_tokens/${this.rememberCode}`,
                    {},
                    {
                        errorMessage:
                            'error.messages.inviteLink.loadRemeberToken',
                    },
                );

                const me = await loggedInPerson.load();

                if (me.user.id.toString() === data.user_id.toString()) {
                    sessionStorageService.clear('inviteState');
                    $location.url(`/ministries/${this.orgId}/suborgs`);
                    $scope.$apply();
                } else {
                    $state.go('appWithoutMenus.mergeAccount', inviteState);
                }
            } catch (e) {
                this.errorWithLink = true;
                sessionStorageService.clear('inviteState');
                $scope.$apply();
            }
        }
    };
}
