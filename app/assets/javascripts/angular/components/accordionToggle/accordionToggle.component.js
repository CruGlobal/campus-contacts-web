(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('accordionToggle', {
            controller: accordionToggleController,
            require: {
                accordion: '^accordion'
            },
            templateUrl: '/assets/angular/components/accordionToggle/accordionToggle.html'
        });

    function accordionToggleController () {
        var vm = this;

        vm.toggleVisibility = toggleVisibility;

        function toggleVisibility () {
            vm.accordion.collapsed = !vm.accordion.collapsed;
        }
    }
})();
