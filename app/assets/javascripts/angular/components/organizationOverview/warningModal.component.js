import template from './warningModal.html';
import './warningModal.scss';

angular.module('missionhubApp').component('warningModal', {
    template: template,
    bindings: {
        resolve: '<',
        dismiss: '&',
        close: '&',
    },
});
