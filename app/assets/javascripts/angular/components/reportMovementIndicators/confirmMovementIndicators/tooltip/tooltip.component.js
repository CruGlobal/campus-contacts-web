import template from './tooltip.html';
import './tooltip.scss';

angular.module('missionhubApp').component('tooltip', {
    bindings: {
        content: '@',
    },
    template,
});
