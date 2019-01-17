import template from './organizationSignaturesSign.html';

angular.module('missionhubApp').component('organizationSignaturesSign', {
    template: template,
    controller: organizationSignaturesSignController,
});

function organizationSignaturesSignController(
    state,
    authenticationService,
    httpProxy,
    $state,
    $rootScope,
    $scope,
) {
    this.nonSignedAgreements = ['code_of_conduct', 'statement_of_faith'];

    let deregisterStateChangedEvent;

    const sendAgreement = (orgId, type, status) => {
        const params = {
            include: [],
            data: {
                attributes: {
                    kind: type,
                    status: status,
                },
            },
        };

        return httpProxy.post(`/organizations/${orgId}/signatures`, params, {
            errorMessage: 'error.messages.surveys.loadQuestions',
        });
    };

    const updateAllAgreements = async (orgIds, type, status) => {
        for (const orgId of orgIds) {
            await sendAgreement(orgId, type, status);
        }
    };

    const updateAgreement = async (type, status) => {
        await updateAllAgreements(
            state.organization_with_missing_signatures_ids,
            type,
            status,
        );

        this.nonSignedAgreements = this.nonSignedAgreements.filter(
            t => t !== type,
        );

        if (this.nonSignedAgreements.length <= 0) {
            authenticationService.updateUserData();
            $state.go('app.people');
        }

        $scope.$apply();
    };

    const hasAgreedTo = type => {
        const signed = this.nonSignedAgreements.find(t => t === type);
        return !signed;
    };

    this.$onInit = () => {
        authenticationService.updateUserData();

        deregisterStateChangedEvent = $rootScope.$on(
            'state:changed',
            (event, data) => {
                if (data.organization_with_missing_signatures_ids.length <= 0)
                    $state.go('app.people');
            },
        );
    };

    this.$onDestroy = () => {
        deregisterStateChangedEvent();
    };

    this.acceptAgreement = async type => {
        updateAgreement(type, 'accepted');
    };

    this.declineAgreement = async type => {
        updateAgreement(type, 'declined');
    };

    this.hasSignedCodeOfConduct = () => {
        return hasAgreedTo('code_of_conduct');
    };

    this.hasSignedSignedStatementOfFaith = () => {
        return hasAgreedTo('statement_of_faith');
    };
}
