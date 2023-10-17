import template from './statsHeader.html';
import './statsHeader.scss';

angular.module('campusContactsApp').component('statsHeader', {
  controller: statsHeaderController,
  template,
});

function statsHeaderController(interactionsService) {
  const vm = this;

  // Exclude the notes interaction type
  vm.interactionTypes = interactionsService.getInteractionTypes().filter(function (interactionType) {
    return interactionType.id !== 1;
  });
}
