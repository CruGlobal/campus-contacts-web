(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('accordionToggle', {
            controller: accordionToggleController,
            require: {
                accordion: '^'
            },
            templateUrl: /* @ngInject */ function (templateUrl) {
                return templateUrl('accordionToggle');
            }
        });

    function accordionToggleController () {
        var vm = this;

        vm.toggleVisibility = toggleVisibility;

        function toggleVisibility () {
            vm.accordion.collapsed = !vm.accordion.collapsed;
        }
    }
})();
