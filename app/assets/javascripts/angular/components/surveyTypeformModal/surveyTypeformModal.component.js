import i18next from 'i18next';

import template from './surveyTypeformModal.html';
import './surveyTypeformModal.scss';

angular.module('missionhubApp').component('surveyTypeformModal', {
    controller: surveyTypeformModalController,
    template: template,
    bindings: {
        resolve: '<',
        close: '&',
    },
});

function surveyTypeformModalController($document, $sce) {
    var vm = this;
    vm.$document = $document;
    this.ministriesSurveysTypeformStep1 = $sce.trustAsHtml(
        i18next.t('ministries.surveys.typeform.step1'),
    );

    vm.copy = () => {
        const el = vm.$document[0].getElementById('missionhub-url');
        el.select();
        vm.$document[0].execCommand('copy');
        vm.copied = true;
    };
}
