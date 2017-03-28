(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('personAssigned', {
            controller: personAssignedController,
            require: {
                personTab: '^personPage'
            },
            templateUrl: /* @ngInject */ function (templateUrl) {
                return templateUrl('personAssigned');
            }
        });

    function personAssignedController (personAssignedService) {
        var vm = this;
        vm.assignments = null;
        vm.$onInit = activate;

        function activate () {
            personAssignedService.getAssigned(vm.personTab.person, vm.personTab.organizationId)
                .then(function (assignments) {
                    vm.assignments = assignments;
                });
        }
    }
})();
