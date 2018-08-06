import template from './surveyHeader.html';
import './surveyHeader.scss';
import chevronLeftIcon from '../../../../images/icons/chevronLeft.svg';

angular.module('missionhubApp').component('surveyHeader', {
    controller: surveyHeaderController,
    bindings: {
        survey: '<',
        previewBtn: '<',
    },
    template: template,
    transclude: true,
});

function surveyHeaderController() {
    this.chevronLeftIcon = chevronLeftIcon;
}
