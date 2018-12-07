import template from './organizationContactImportStep2.html';
import * as Papa from 'papaparse';
import _ from 'lodash';

angular.module('missionhubApp').component('organizationContactImportStep2', {
    bindings: {
        next: '&',
        previous: '&',
        csvData: '<',
        selectedSurvey: '<',
        columnMap: '<',
    },
    template: template,
    controller: organizationContactImportStep2Controller,
});

function organizationContactImportStep2Controller($scope, surveyService) {
    this.currentPreviewRow = 1;

    this.$onInit = () => {
        //get survey questions
        surveyService
            .getSurveyQuestions(this.selectedSurvey.id)
            .then(questions => {
                this.surveyQuestions = questions.data;
            });
    };

    this.doNotImportColumn = index => {
        if (this.columnMap[index]) {
            delete this.columnMap[index];
        }
    };

    this.questionInUse = questionId => {
        return _.includes(_.map(this.columnMap, 'id'), questionId);
    };

    this.canContinue = () => {
        return Object.keys(this.columnMap).length > 0;
    };

    this.nextPreviewRow = () => {
        this.currentPreviewRow =
            this.currentPreviewRow + 1 < this.csvData.length
                ? this.currentPreviewRow + 1
                : this.currentPreviewRow;
    };

    this.previousPreviewRow = () => {
        this.currentPreviewRow =
            this.currentPreviewRow - 1 > 0
                ? this.currentPreviewRow - 1
                : this.currentPreviewRow;
    };
}
