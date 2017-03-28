(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('interaction', {
            controller: interactionController,
            templateUrl: /* @ngInject */ function (templateUrl) {
                return templateUrl('interaction');
            },
            bindings: {
                person: '<',
                interaction: '<'
            }
        });

    function interactionController (interactionsService) {
        var vm = this;
        vm.$onInit = activate;

        function activate () {
            vm.interactionType = interactionsService.getInteractionType(vm.interaction.interaction_type_id);
        }
    }
})();
