(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('statsHeader', {
            controller: statsHeaderController,
            templateUrl: /* @ngInject */ function (templateUrl) {
                return templateUrl('statsHeader');
            }
        });

    function statsHeaderController (interactionsService) {
        var vm = this;

        // Exclude the notes interaction type
        vm.interactionTypes = interactionsService.getInteractionTypes().filter(function (interactionType) {
            return interactionType.id !== 1;
        });
    }
})();
