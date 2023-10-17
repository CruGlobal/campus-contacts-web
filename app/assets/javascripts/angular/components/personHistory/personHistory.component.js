import template from './personHistory.html';
import './personHistory.scss';

angular.module('campusContactsApp').component('personHistory', {
  controller: personHistoryController,
  bindings: {
    history: '<',
  },
  require: {
    personTab: '^personPage',
  },
  template,
});

function personHistoryController(
  $scope,
  $element,
  $window,
  $interval,
  $q,
  asyncBindingsService,
  interactionsService,
  personHistoryService,
  _,
) {
  const vm = this;
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

  function activate() {
    vm.interactionTypes = interactionsService.getInteractionTypes();
    $scope.$watchGroup(
      ['$ctrl.filter', '$ctrl.personTab.person.interactions', '$ctrl.personTab.person.answer_sheets'],
      buildHistoryFeed,
    );

    vm.organizationId = vm.personTab.organizationId;
  }

  function createInteraction(interactionType) {
    vm.newInteractionType = interactionType;
    vm.closeInteractionTypeSheet();

    scrollToBottom();
    findAsync('.new-interaction textarea').then(function (input) {
      input.focus();
    });
  }

  // Save the new interaction on the server
  function saveInteraction() {
    const interaction = {
      interactionTypeId: vm.newInteractionType.id,
      comment: vm.newInteractionComment,
    };
    const personId = vm.personTab.person.id;
    return interactionsService.recordInteraction(interaction, vm.organizationId, personId).then(function () {
      vm.clearInteraction();
    });
  }

  // Hide the new interaction form
  function clearInteraction() {
    vm.newInteractionType = null;
    vm.newInteractionComment = null;
  }

  // Open the interaction type sheet
  function openInteractionTypeSheet() {
    vm.interactionTypesVisible = true;
  }

  // Close the interaction type sheet
  function closeInteractionTypeSheet() {
    vm.interactionTypesVisible = false;
  }

  // Remove server deleted interaction locally
  function removeInteraction($event) {
    if ($event.interaction._type === 'interaction') {
      _.pull(vm.personTab.person.interactions, $event.interaction);
    } else if ($event.interaction._type === 'answer_sheet') {
      _.pull(vm.personTab.person.answer_sheets, $event.interaction);
    }
    buildHistoryFeed();
  }

  // Scroll to the bottom of the history list
  function scrollToBottom() {
    const scrollContainer = $window.document.getElementsByClassName('scrollable-area')[0];
    scrollContainer.scrollTop = scrollContainer.scrollHeight;
  }

  // Find an element that may not exist yet and return a promise that resolves to the element when it exists
  function findAsync(selector) {
    return $q(function (resolve) {
      var interval = $interval(function () {
        const element = $element.find(selector);
        if (element.length > 0) {
          $interval.cancel(interval);
          resolve(element);
        }
      });
    });
  }

  function buildHistoryFeed() {
    vm.historyFeed = personHistoryService.buildHistoryFeed(vm.personTab.person, vm.filter, vm.personTab.organizationId);
  }
}
