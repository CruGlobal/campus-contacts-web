(function () {
    'use strict';

    /*
     * The icon-button component represents an actionable button displayed as an icon. If it is disabled, it prevents
     * click events from propagating to its parent, thus effectively disabling the action of its parent, whether that
     * action is an ng-click handler, an href link, a ui-sref link, or some other click-based action.
     */

    angular
        .module('missionhubApp')
        .component('iconButton', {
            controller: iconButtonController,
            bindings: {
                disabled: '<',
                icon: '<'
            },
            templateUrl: /* @ngInject */ function (templateUrl) {
                return templateUrl('iconButton');
            }
        });

    function iconButtonController () {
        var vm = this;

        vm.handleClick = handleClick;

        function handleClick (event) {
            if (vm.disabled) {
                event.preventDefault();
                event.stopPropagation();
            }
        }
    }
})();
