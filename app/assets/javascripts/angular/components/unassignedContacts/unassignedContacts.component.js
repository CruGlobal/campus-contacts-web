(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('unassignedContacts', {
            controller: unassignedContactsController,
            require: {
                organization: '^organization'
            },
            templateUrl: '/assets/angular/components/unassignedContacts/unassignedContacts.html'
        });

    function unassignedContactsController (lscache) {
        var vm = this;
        vm.setUnassignedVisible = setUnassignedVisible;

        vm.$onInit = activate;

        function getUnassignedVisibleKey () {
            return ['unassignedVisible', vm.organization.org.id].join(':');
        }

        function activate () {
            var val = lscache.get(getUnassignedVisibleKey());
            vm.unassignedVisible = (val === null) ? true : val;
        }

        function setUnassignedVisible (value) {
            vm.unassignedVisible = Boolean(value);
            lscache.set(getUnassignedVisibleKey(), vm.unassignedVisible, 24 * 60); // 24 hour expiry
        }
    }
})();
