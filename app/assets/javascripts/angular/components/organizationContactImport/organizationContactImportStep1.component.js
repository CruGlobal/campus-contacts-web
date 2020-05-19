import * as Papa from 'papaparse';

import fileIcon from '../../../../images/icons/icon-file.svg';
import warningIcon from '../../../../images/icons/icon-warning.svg';
import errorIcon from '../../../../images/icons/icon-error.svg';

import template from './organizationContactImportStep1.html';

angular.module('missionhubApp').component('organizationContactImportStep1', {
    bindings: {
        org: '<',
        surveys: '<',
        next: '&',
        selectedSurvey: '<',
        fileName: '<',
        csvData: '<',
    },
    template: template,
    controller: organizationContactImportStep1Controller,
});

function organizationContactImportStep1Controller($scope, $uibModal, $state) {
    this.fileIcon = fileIcon;
    this.warningIcon = warningIcon;
    this.errorIcon = errorIcon;
    this.isInteger = Number.isInteger;

    this.selectFile = () => {
        // eslint-disable-next-line angular/document-service
        const input = document.createElement('input');
        input.setAttribute('type', 'file');
        input.setAttribute('accept', '.csv');
        input.click();

        input.addEventListener(
            'change',
            () => {
                $scope.$apply(() => {
                    this.fileTypeError = false;
                    delete this.csvData;
                    delete this.parseErrors;
                    const file = input.files[0];
                    const fileExtension = file.name.split('.').pop();
                    this.fileName = file.name;

                    if (fileExtension === 'csv') {
                        this.parseCsv(file);
                    } else {
                        this.fileTypeError = true;
                        delete this.csvData;
                        delete this.fileName;
                    }
                });
            },
            false,
        );
    };

    this.parseCsv = (file) => {
        Papa.parse(file, {
            skipEmptyLines: 'greedy',
            complete: (results) => {
                $scope.$apply(() => {
                    if (results.errors.length) {
                        this.parseErrors = results.errors;
                    }
                    this.csvData = results.data;
                });
            },
        });
    };

    this.createSurvey = () => {
        const modal = $uibModal
            .open({
                component: 'createSurvey',
                resolve: {
                    organizationId: () => this.org.id,
                },
                windowClass: 'pivot_theme',
                size: 'sm',
            })
            .result.then((newSurvey) => {
                $state.go('app.ministries.ministry.survey.manage', {
                    surveyId: newSurvey.id,
                });
            });
    };
}
