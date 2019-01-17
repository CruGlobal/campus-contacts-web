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

    const updateAgreement = (type, status) => {
        state.organization_with_missing_signatures_ids.forEach(async orgId => {
            await sendAgreement(orgId, type, status);
        });

        this.nonSignedAgreements = this.nonSignedAgreements.filter(
            t => t !== type,
        );

        if (this.nonSignedAgreements.length <= 0) {
            authenticationService.updateUserData();
            $state.go('app.people');
        }
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
