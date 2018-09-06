import template from './deleteOrgConfirmModal.html';
import './deleteOrgConfirmModal.scss';
import warningIcon from '../../../../images/icons/icon-warning-2.svg';

angular.module('missionhubApp').component('deleteOrgConfirmModal', {
    controller: deleteOrgConfirmModalController,
    template: template,
    bindings: {
        resolve: '<',
        close: '&',
        dismiss: '&',
    },
});

function deleteOrgConfirmModalController() {
    this.warningIcon = warningIcon;
}
