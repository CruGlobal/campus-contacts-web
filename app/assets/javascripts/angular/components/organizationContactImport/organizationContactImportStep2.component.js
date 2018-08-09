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
    this.$onInit = () => {
        //get survey questions
        surveyService
            .getSurveyQuestions(this.selectedSurvey.id)
            .then(questions => {
                this.surveyQuestions = questions;
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
}
