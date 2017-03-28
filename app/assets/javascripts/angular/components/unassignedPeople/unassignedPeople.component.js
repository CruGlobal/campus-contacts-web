(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('unassignedPeople', {
            controller: unassignedPeopleController,
            require: {
                organization: '^'
            },
            templateUrl: /* @ngInject */ function (templateUrl) {
                return templateUrl('unassignedPeople');
            }
        });

    function unassignedPeopleController (lscache) {
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
