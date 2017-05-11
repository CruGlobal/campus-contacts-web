(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('accordion', {
            controller: accordionController,
            bindings: {
                collapsed: '=?',
                collapsible: '=?',
                accordionDisabled: '<'
            },
            templateUrl: /* @ngInject */ function (templateUrl) {
                return templateUrl('accordion');
            },
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
