import template from './deleteQuestionConfirmModal.html';
import './deleteQuestionConfirmModal.scss';
import warningIcon from '../../../../images/icons/icon-warning-2.svg';

angular.module('missionhubApp').component('deleteQuestionConfirmModal', {
    controller: deleteQuestionConfirmModalController,
    template: template,
    bindings: {
        resolve: '<',
        close: '&',
        dismiss: '&',
    },
});

function deleteQuestionConfirmModalController() {
    this.warningIcon = warningIcon;
}
