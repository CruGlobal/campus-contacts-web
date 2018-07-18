import template from './keywordRequestModal.html';
import './keywordRequestModal.scss';
import clockIcon from '../../../../images/icon-clock.svg';

angular.module('missionhubApp').component('keywordRequestModal', {
    controller: keywordRequestModalController,
    template: template,
    bindings: {
        resolve: '<',
        close: '&',
        dismiss: '&',
    },
});

function keywordRequestModalController() {
    this.clockIcon = clockIcon;
}
