(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('personHistory', {
            controller: personHistoryController,
            require: {
                personTab: '^personPage'
            },
            templateUrl: '/assets/angular/components/personHistory/personHistory.html'
        });

    function personHistoryController ($scope, interactionsService, personHistoryService) {
        var vm = this;
        vm.filters = ['all', 'interactions', 'notes', 'surveys'];
        vm.filter = vm.filters[0];
        vm.historyFeed = null;
        vm.interactionTypesVisible = false;
        vm.newInteractionType = null;
        vm.newInteractionComment = null;
        vm.createInteraction = createInteraction;
        vm.saveInteraction = saveInteraction;
        vm.clearInteraction = clearInteraction;
        vm.$onInit = activate;

        function activate () {
            vm.interactionTypes = interactionsService.getInteractionTypes();
            $scope.$watchGroup([
                '$ctrl.filter', '$ctrl.personTab.person.interactions', '$ctrl.personTab.person.answer_sheets'
            ], function () {
                vm.historyFeed = personHistoryService.buildHistoryFeed(vm.personTab.person, vm.filter);
            });

            vm.organizationId = vm.personTab.organizationId;
        }

        function createInteraction (interactionType) {
            vm.newInteractionType = interactionType;
            vm.interactionTypesVisible = false;
        }

        // Save the new interaction on the server
        function saveInteraction () {
            var interaction = {
                interactionTypeId: vm.newInteractionType.id,
                comment: vm.newInteractionComment
            };
            var personId = vm.personTab.person.id;
            return interactionsService.recordInteraction(interaction, vm.organizationId, personId).then(function () {
                vm.clearInteraction();
            });
        }

        // Hide the new interaction form
        function clearInteraction () {
            vm.newInteractionType = null;
            vm.newInteractionComment = null;
        }
    }
})();
