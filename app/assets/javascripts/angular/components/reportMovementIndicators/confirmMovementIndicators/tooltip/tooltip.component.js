import template from './tooltip.html';
import './tooltip.scss';

angular.module('campusContactsApp').component('tooltip', {
    bindings: {
        content: '@',
    },
    template,
});
