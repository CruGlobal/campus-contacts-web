import template from './errorRetryToastTemplate.html';

angular
    .module('missionhubApp')
    .directive('errorRetryToastTemplate', function() {
        return {
            template: template,
        };
    });
