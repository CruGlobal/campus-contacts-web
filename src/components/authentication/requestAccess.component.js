import template from './requestAccess.html';

angular.module('missionhubApp').component('requestAccess', {
    controller: requestAccessController,
    template: template,
});

function requestAccessController(
    authenticationService,
    httpProxy,
    $state,
    $scope,
) {
    this.formSubmitted = false;
    this.formSubmitting = false;

    this.$onInit = async () => {
        if (authenticationService.isTokenValid()) $state.go('app.people');
    };

    this.requestAccess = async requestData => {
        this.formSubmitting = true;

        const params = {
            type: 'access_request',
            attributes: {
                first_name: requestData.firstName,
                last_name: requestData.lastName,
                email: requestData.email,
                org_name: requestData.organizationName,
            },
        };

        await httpProxy.post(
            '/access_requests',
            {
                data: params,
            },
            {
                errorMessage: 'error.messages.requestAccess',
            },
        );

        this.formSubmitted = true;
        this.formSubmitting = false;

        $scope.$apply();
    };
}
