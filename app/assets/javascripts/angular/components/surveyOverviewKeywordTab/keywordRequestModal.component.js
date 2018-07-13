import template from './keywordRequestModal.html';

angular.module('missionhubApp').component('keywordRequestModal', {
    controller: keywordRequestModalController,
    template: template,
    bindings: {
        resolve: '<',
        close: '&',
        dismiss: '&',
    },
});

function keywordRequestModalController() {}
