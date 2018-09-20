import template from './iconModal.html';
import './iconModal.scss';

angular.module('missionhubApp').component('iconModal', {
    template: template,
    bindings: {
        resolve: '<',
        close: '&',
        dismiss: '&',
    },
});
