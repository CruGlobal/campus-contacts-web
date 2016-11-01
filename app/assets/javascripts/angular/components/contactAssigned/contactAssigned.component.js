(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('contactAssigned', {
            controller: contactAssignedController,
            require: {
                contactTab: '^organizationOverviewContact'
            },
            templateUrl: '/assets/angular/components/contactAssigned/contactAssigned.html'
        });

    function contactAssignedController (contactAssignedService) {
        var vm = this;
        vm.assignments = null;
        vm.$onInit = activate;

        function activate () {
            contactAssignedService.getAssigned(vm.contactTab.contact, vm.contactTab.organizationId)
                .then(function (assignments) {
                    vm.assignments = assignments;
                });
        }
    }
})();
