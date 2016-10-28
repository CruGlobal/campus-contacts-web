(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('statsHeader', {
            controller: statsHeaderController,
            templateUrl: '/assets/angular/components/statsHeader/statsHeader.html'
        });

    function statsHeaderController (interactionsService) {
        var vm = this;
        // Exclude the notes interaction type
        vm.interactionTypes = interactionsService.getInteractionTypes().filter(function (interactionType) {
            return interactionType.id !== 1;
        });
    }
})();
