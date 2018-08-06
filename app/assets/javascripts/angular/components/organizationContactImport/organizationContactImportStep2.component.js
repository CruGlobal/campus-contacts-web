import template from './organizationContactImportStep2.html';
import * as Papa from 'papaparse';
import _ from 'lodash';

angular.module('missionhubApp').component('organizationContactImportStep2', {
    require: {
        organizationOverview: '^',
    },
    bindings: {
        next: '&',
        previous: '&',
        selectedFile: '<',
        selectedSurvey: '<',
        columnMap: '<',
    },
    template: template,
    controller: organizationContactImportStep2Controller,
});

function organizationContactImportStep2Controller($scope, surveyService) {
    this.$onInit = () => {
        //get first two rows of CSV
        Papa.parse(this.selectedFile, {
            preview: 2,
            complete: results => {
                this.csvData = results.data;
                $scope.$digest();
            },
        });

        //get survey questions
        surveyService
            .getSurveyQuestions(this.selectedSurvey.id)
            .then(questions => {
                this.surveyQuestions = questions;
            });
    };

    this.questionInUse = questionId => {
        return _.includes(_.map(this.columnMap, 'id'), questionId);
    };

    this.canContinue = () => {
        return Object.keys(this.columnMap).length > 0;
    };
}
