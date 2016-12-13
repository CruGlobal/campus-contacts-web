(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('personAssigned', {
            controller: personAssignedController,
            require: {
                personTab: '^personPage'
            },
            templateUrl: '/assets/angular/components/personAssigned/personAssigned.html'
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
