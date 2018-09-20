import template from './suggestedActions.html';

angular
    .module('missionhubApp')
    .component('reportMovementIndicatorsSuggestedActions', {
        controller: reportMovementIndicatorsSuggestedActionsController,
        bindings: {
            orgId: '<',
            next: '&',
        },
        template,
    });

function reportMovementIndicatorsSuggestedActionsController() {}
