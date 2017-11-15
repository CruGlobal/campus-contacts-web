import template from './answerSheet.html';
import './answerSheet.scss';

angular
    .module('missionhubApp')
    .component('answerSheet', {
        template: template,
        bindings: {
            answerSheet: '<',
            organizationId: '<'
        }
    });

