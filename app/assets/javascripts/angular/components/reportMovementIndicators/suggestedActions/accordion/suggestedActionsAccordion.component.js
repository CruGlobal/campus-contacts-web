import { t } from 'i18next';

import template from './suggestedActionsAccordion.html';
import './suggestedActionsAccordion.scss';

angular
    .module('missionhubApp')
    .component('reportMovementIndicatorsSuggestedActionsAccordion', {
        controller: reportMovementIndicatorsSuggestedActionsController,
        bindings: {
            title: '@',
            suggestions: '<',
            acceptedIds: '<',
            rejectedIds: '<',
            handleSuggestionActionClick: '<',
            handleAllClick: '<',
            accordionOpenByDefault: '<',
        },
        template,
    });

function reportMovementIndicatorsSuggestedActionsController($sce) {
    this.$onInit = () => (this.accordionOpen = this.accordionOpenByDefault);

    this.isAccepted = id => this.acceptedIds.has(id);
    this.isRejected = id => this.rejectedIds.has(id);

    this.getLabelQuestion = action =>
        $sce.trustAsHtml(
            t('movementIndicators:suggestedActions.applyLabel', {
                label: action.label.i18n
                    ? t(action.label.i18n)
                    : action.label.name,
            }),
        );
}
