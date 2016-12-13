(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('interaction', {
            controller: interactionController,
            templateUrl: '/assets/angular/components/interaction/interaction.html',
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
