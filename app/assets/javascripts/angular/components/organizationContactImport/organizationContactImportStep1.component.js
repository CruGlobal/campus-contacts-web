import * as Papa from 'papaparse';

import template from './organizationContactImportStep1.html';

import fileIcon from '../../../../images/icons/icon-file.svg';
import warningIcon from '../../../../images/icons/icon-warning.svg';
import errorIcon from '../../../../images/icons/icon-error.svg';

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

function organizationContactImportStep1Controller($scope) {
    this.fileIcon = fileIcon;
    this.warningIcon = warningIcon;
    this.errorIcon = errorIcon;
    this.isInteger = Number.isInteger;

    this.selectFile = () => {
        // eslint-disable-next-line angular/document-service
        const input = document.createElement('input');
        input.setAttribute('type', 'file');
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

    this.parseCsv = file => {
        Papa.parse(file, {
            skipEmptyLines: 'greedy',
            complete: results => {
                $scope.$apply(() => {
                    if (results.errors.length) {
                        this.parseErrors = results.errors;
                    }
                    this.csvData = results.data;
                });
            },
        });
    };
}
