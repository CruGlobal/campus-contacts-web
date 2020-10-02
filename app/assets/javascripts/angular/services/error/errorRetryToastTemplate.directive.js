import template from './errorRetryToastTemplate.html';

angular
    .module('campusContactsApp')
    .directive('errorRetryToastTemplate', function () {
        return {
            template: template,
        };
    });
