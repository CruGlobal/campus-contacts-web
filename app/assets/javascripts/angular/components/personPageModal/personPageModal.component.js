(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('personPageModal', {
            controller: personPageModalController,
            templateUrl: '/assets/angular/components/personPageModal/personPageModal.html',
            bindings: {
                resolve: '<',
                close: '&',
                dismiss: '&'
            }
        });

    function personPageModalController () {
        var vm = this;
        vm.$onInit = activate;

        function activate () {
            vm.person = vm.resolve.person;
            vm.organizationId = vm.resolve.organizationId;
        }
    }
})();
