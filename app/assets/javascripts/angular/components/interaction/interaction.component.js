import moment from 'moment';

import template from './interaction.html';
import './interaction.scss';

angular.module('missionhubApp').component('interaction', {
    controller: interactionController,
    template: template,
    bindings: {
        person: '<',
        interaction: '<',
        onDelete: '&',
    },
});

function interactionController(
    interactionsService,
    confirmModalService,
    $filter,
) {
    var vm = this;

    vm.editInteraction = false;
    vm.moment = moment;

    vm.$onInit = activate;
    vm.updateInteraction = updateInteraction;
    vm.deleteInteraction = deleteInteraction;

    vm.modifyInteractionState = 'view';

    function activate() {
        vm.interactionType = interactionsService.getInteractionType(
            vm.interaction.interaction_type_id,
        );
    }

    function updateInteraction() {
        vm.modifyInteractionState = 'saving';
        return interactionsService
            .updateInteraction(vm.interaction)
            .then(function() {
                vm.modifyInteractionState = 'view';
            })
            .catch(function() {
                vm.modifyInteractionState = 'edit';
            });
    }

    function deleteInteraction() {
        vm.modifyInteractionState = 'saving';
        return confirmModalService
            .create($filter('t')('interactions.delete_confirmation'))
            .then(function() {
                return interactionsService.deleteInteraction(vm.interaction);
            })
            .then(function() {
                vm.onDelete({
                    $event: {
                        interaction: vm.interaction,
                    },
                });
            })
            .catch(function() {
                vm.modifyInteractionState = 'view';
            });
    }
}
