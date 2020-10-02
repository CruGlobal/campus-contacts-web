import template from './iconModal.html';
import './iconModal.scss';

angular.module('campusContactsApp').component('iconModal', {
    template: template,
    bindings: {
        resolve: '<',
        close: '&',
        dismiss: '&',
    },
});
