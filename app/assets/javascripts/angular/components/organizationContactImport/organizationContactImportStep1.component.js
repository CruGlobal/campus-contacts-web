import template from './organizationContactImportStep1.html';

import fileIcon from '../../../../images/icon-file.svg';

angular.module('missionhubApp').component('organizationContactImportStep1', {
    require: {
        organizationOverview: '^',
    },
    bindings: {
        next: '&',
        selectedSurvey: '<',
    },
    template: template,
    controller: organizationContactImportStep1Controller,
});

function organizationContactImportStep1Controller($scope) {
    this.fileIcon = fileIcon;

    this.selectFile = () => {
        const input = document.createElement('input');
        input.setAttribute('type', 'file');
        input.click();

        input.addEventListener(
            'change',
            () => {
                this.selectedFile = input.files[0];

                if (this.selectedFile.type !== 'text/csv') {
                    this.selectedFile = null;
                }

                $scope.$digest();
            },
            false,
        );
    };
}
