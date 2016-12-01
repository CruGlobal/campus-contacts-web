(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('contactHistory', {
            controller: contactHistoryController,
            require: {
                contactTab: '^organizationOverviewContact'
            },
            templateUrl: '/assets/angular/components/contactHistory/contactHistory.html'
        });

    function contactHistoryController ($scope, interactionsService, contactHistoryService) {
        var vm = this;
        vm.filters = ['all', 'interactions', 'notes', 'surveys'];
        vm.filter = vm.filters[0];
        vm.historyFeed = null;
        vm.interactionTypesVisible = false;
        vm.newInteractionType = null;
        vm.newInteractionComment = null;
        vm.interactionTypes = interactionsService.getInteractionTypes();
        vm.createInteraction = createInteraction;
        vm.saveInteraction = saveInteraction;
        vm.clearInteraction = clearInteraction;
        vm.$onInit = activate;

        function activate () {
            $scope.$watchGroup([
                '$ctrl.filter', '$ctrl.contactTab.contact.interactions', '$ctrl.contactTab.contact.answer_sheets'
            ], function () {
                vm.historyFeed = contactHistoryService.buildHistoryFeed(vm.contactTab.contact, vm.filter);
            });

            vm.organizationId = vm.contactTab.organizationId;
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
            var contactId = vm.contactTab.contact.id;
            return interactionsService.recordInteraction(interaction, vm.organizationId, contactId).then(function () {
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
