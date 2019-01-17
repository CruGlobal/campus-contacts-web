import template from './organizationSignaturesSign.html';

angular.module('missionhubApp').component('organizationSignaturesSign', {
    template: template,
    controller: organizationSignaturesSignController,
});

function organizationSignaturesSignController(state, authenticationService) {
    this.$onInit = () => {};

    this.signAgreement = () => {};
}
