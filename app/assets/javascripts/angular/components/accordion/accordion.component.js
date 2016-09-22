(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('accordion', {
            controller: accordionController,
            bindings: {
                collapsed: '=?',
                collapsible: '=?'
            },
            templateUrl: '/assets/angular/components/accordion/accordion.html',
            transclude: {
                header: 'accordionHeader',
                content: 'accordionContent'
            }
        });

    function accordionController (_) {
        var vm = this;

        vm.toggleVisibility = toggleVisibility;

        _.defaults(vm, {
            collapsed: true,
            collapsible: true
        });

        function toggleVisibility () {
            vm.collapsed = !vm.collapsed;
        }
    }
})();
