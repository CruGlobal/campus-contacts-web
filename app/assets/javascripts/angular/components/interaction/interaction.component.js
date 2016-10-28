(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('interaction', {
            controller: interactionController,
            templateUrl: '/assets/angular/components/interaction/interaction.html',
            bindings: {
                contact: '<',
                interaction: '<'
            }
        });

    function interactionController (interactionsService, _) {
        var vm = this;
        vm.$onInit = activate;

        function activate () {
            vm.interactionType = _.find(interactionsService.getInteractionTypes(), {
                id: vm.interaction.interaction_type_id
            });
        }
    }
})();
