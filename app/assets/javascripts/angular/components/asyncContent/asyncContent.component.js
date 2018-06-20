import template from './asyncContent.html';
import './asyncContent.scss';

angular.module('missionhubApp').component('asyncContent', {
    bindings: {
        ready: '<',
    },
    template: template,
    transclude: true,
});
