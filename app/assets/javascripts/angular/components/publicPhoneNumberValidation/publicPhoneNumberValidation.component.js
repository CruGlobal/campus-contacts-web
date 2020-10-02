import template from './publicPhoneNumberValidation.html';

angular.module('campusContactsApp').component('publicPhoneNumberValidation', {
    bindings: {
        phoneNumberValidation: '<',
    },
    template,
});
