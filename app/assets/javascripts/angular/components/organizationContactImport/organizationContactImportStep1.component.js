import template from './organizationContactImportStep1.html';

import fileIcon from '../../../../images/icons/icon-file.svg';
import errorIcon from '../../../../images/icons/icon-error.svg';

angular.module('missionhubApp').component('organizationContactImportStep1', {
    bindings: {
        org: '<',
        surveys: '<',
        next: '&',
        selectedSurvey: '<',
    },
    template: template,
    controller: organizationContactImportStep1Controller,
});

function organizationContactImportStep1Controller($scope) {
    this.fileIcon = fileIcon;
    this.errorIcon = errorIcon;

    this.selectFile = () => {
        this.fileError = false;

        // eslint-disable-next-line angular/document-service
        const input = document.createElement('input');
        input.setAttribute('type', 'file');
        input.click();

        input.addEventListener(
            'change',
            () => {
                this.selectedFile = input.files[0];

                if (this.selectedFile.type !== 'text/csv') {
                    this.fileError = true;
                    this.selectedFile = null;
                }

                $scope.$digest();
            },
            false,
        );
    };
}
