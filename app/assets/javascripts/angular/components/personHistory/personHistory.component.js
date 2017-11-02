(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('personHistory', {
            controller: personHistoryController,
            bindings: {
                history: '<'
            },
            require: {
                personTab: '^personPage'
            },
            templateUrl: /* @ngInject */ function (templateUrl) {
                return templateUrl('personHistory');
            }
        });

    function personHistoryController ($scope, $element, $interval, $q, asyncBindingsService,
                                      interactionsService, personHistoryService, _) {
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
        vm.openInteractionTypeSheet = openInteractionTypeSheet;
        vm.closeInteractionTypeSheet = closeInteractionTypeSheet;
        vm.removeInteraction = removeInteraction;
        vm.$onInit = asyncBindingsService.lazyLoadedActivate(activate, ['history']);

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
            vm.closeInteractionTypeSheet();

            scrollToBottom();
            findAsync('.new-interaction textarea').then(function (input) {
                input.focus();
            });
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

        // Open the interaction type sheet
        function openInteractionTypeSheet () {
            vm.interactionTypesVisible = true;
        }

        // Close the interaction type sheet
        function closeInteractionTypeSheet () {
            vm.interactionTypesVisible = false;
        }

        // Remove server deleted interaction locally
        function removeInteraction ($event) {
            _.pull(vm.historyFeed, $event.interaction);
        }

        // Scroll to the bottom of the history list
        function scrollToBottom () {
            var scrollContainer = $element.find('.scrollable-area')[0];
            scrollContainer.scrollTop = scrollContainer.scrollHeight;
        }

        // Find an element that may not exist yet and return a promise that resolves to the element when it exists
        function findAsync (selector) {
            return $q(function (resolve) {
                var interval = $interval(function () {
                    var element = $element.find(selector);
                    if (element.length > 0) {
                        $interval.cancel(interval);
                        resolve(element);
                    }
                });
            });
        }
    }
})();
