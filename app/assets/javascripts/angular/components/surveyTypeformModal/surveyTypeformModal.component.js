import template from './surveyTypeformModal.html';

angular.module('missionhubApp').component('surveyTypeformModal', {
    controller: surveyTypeformModalController,
    template: template,
    bindings: {
        resolve: '<',
        close: '&',
    },
});

function surveyTypeformModalController($document) {
    var vm = this;
    vm.$document = $document;

    vm.copy = () => {
        const el = vm.$document[0].getElementById('missionhub-url');
        el.select();
        vm.$document[0].execCommand('copy');
        vm.copied = true;
    };
}
