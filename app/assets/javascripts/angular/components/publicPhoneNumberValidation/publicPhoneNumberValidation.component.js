import template from './publicPhoneNumberValidation.html';

angular.module('missionhubApp').component('publicPhoneNumberValidation', {
    bindings: {
        phoneNumberValidation: '<',
    },
    template,
});
