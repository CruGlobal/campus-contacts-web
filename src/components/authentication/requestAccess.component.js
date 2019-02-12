import template from './requestAccess.html';
//import './requestAccess.scss';

angular.module('missionhubApp').component('requestAccess', {
    controller: requestAccessController,
    template: template,
});

function requestAccessController(authenticationService, envService, $state) {
    this.formSubmitted = false;

    this.$onInit = async () => {
        //if (authenticationService.isTokenValid())
        //$state.go('app.people');
    };

    this.requestAccess = async requestData => {
        console.log(requestData);

        return;

        const params = {
            type: 'access_request',
            attributes: {
                first_name: requestData.firstName,
                last_name: requestData.lastName,
                email: requestData.email,
                org_name: requestData.organizationName,
            },
        };

        const { data } = await httpProxy.post(
            '/access_requests',
            {
                data: params,
            },
            {
                errorMessage: 'error.messages.organization.cleanup',
            },
        );

        this.formSubmitted = true;
    };
}
