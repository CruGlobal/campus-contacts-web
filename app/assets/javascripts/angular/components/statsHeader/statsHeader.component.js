import template from './statsHeader.html';
import './statsHeader.scss';

angular
    .module('missionhubApp')
    .component('statsHeader', {
        controller: statsHeaderController,
        template: template
    });

function statsHeaderController (interactionsService) {
    var vm = this;

    // Exclude the notes interaction type
    vm.interactionTypes = interactionsService.getInteractionTypes().filter(function (interactionType) {
        return interactionType.id !== 1;
    });
}
