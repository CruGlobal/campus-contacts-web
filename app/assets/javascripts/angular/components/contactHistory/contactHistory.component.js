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

    function contactHistoryController ($scope, interactionsService, _) {
        var vm = this;
        vm.filters = ['all', 'notes', 'surveys'];
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
                vm.historyFeed = _.sortBy({
                    notes: vm.contactTab.contact.interactions,
                    surveys: vm.contactTab.contact.answer_sheets,
                    all: [].concat(vm.contactTab.contact.interactions, vm.contactTab.contact.answer_sheets)
                }[vm.filter], function (item) {
                    // Pick the sort key based on whether the item is an interaction or an answer sheet
                    if (item._type === 'interaction') {
                        return item.timestamp;
                    }
                    if (item._type === 'answer_sheet') {
                        return item.completed_at;
                    }
                });
            });
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
            var orgId = vm.contactTab.organizationId;
            var contactId = vm.contactTab.contact.id;
            return interactionsService.recordInteraction(interaction, orgId, contactId).then(function (newInteraction) {
                // Create a new array instead of mutating the existing one
                // so that the $watch on interactions changes will trigger
                vm.contactTab.contact.interactions = vm.contactTab.contact.interactions.concat(newInteraction);

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
