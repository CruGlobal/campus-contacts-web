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
    $filter,
    $sce,
) {
    this.nonSignedAgreements = ['code_of_conduct', 'statement_of_faith'];
    this.hasDeclined = false;

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
            errorMessage: 'error.messages.signature_request',
        });
    };

    const updateAllAgreements = async (orgIds, type, status) => {
        await Promise.all(
            orgIds.map(orgId => sendAgreement(orgId, type, status)),
        );
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

        $scope.$apply();
    };

    const hasAgreedTo = type => {
        const signed = this.nonSignedAgreements.find(t => t === type);
        return !signed;
    };

    this.$onInit = () => {
        //authenticationService.updateUserData();

        deregisterStateChangedEvent = $rootScope.$on(
            'state:changed',
            (event, data) => {
                if (data.organization_with_missing_signatures_ids.length <= 0)
                    $state.go('app.people');
            },
        );

        this.codeOfConductText = $sce.trustAsHtml(
            $filter('t')('signatures.agreements.codeOfConduct.text'),
        );
        this.statementOfFaithText = $sce.trustAsHtml(
            $filter('t')('signatures.agreements.statementOfFaith.text'),
        );
    };

    this.$onDestroy = () => {
        deregisterStateChangedEvent();
    };

    this.returnToApp = () => {
        authenticationService.updateUserData();
        $state.go('app.people');
    };

    this.acceptAgreement = async type => {
        updateAgreement(type, 'accepted');
    };

    this.declineAgreement = async type => {
        await updateAgreement(type, 'declined');
        this.hasDeclined = true;
    };

    this.hasSignedCodeOfConduct = () => {
        return hasAgreedTo('code_of_conduct');
    };

    this.hasSignedSignedStatementOfFaith = () => {
        return hasAgreedTo('statement_of_faith');
    };
}
