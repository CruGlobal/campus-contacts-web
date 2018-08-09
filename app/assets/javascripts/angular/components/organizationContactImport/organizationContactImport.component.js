import template from './organizationContactImport.html';
import './organizationContactImport.scss';
import '../surveyOverview/surveyOverview.scss';

angular.module('missionhubApp').component('organizationContactImport', {
    require: {
        organizationOverview: '^',
    },
    template: template,
    controller: organizationContactImportController,
});

function organizationContactImportController() {
    this.columnMap = {};
    this.activeStep = 1;

    this.$onInit = () => {
        this.org = this.organizationOverview.org;
        this.surveys = this.organizationOverview.surveys;
    };

    this.next = (selectedSurvey, fileName, csvData, columnMap) => {
        if (selectedSurvey) {
            this.selectedSurvey = selectedSurvey;
        }
        if (csvData) {
            this.csvData = csvData;
        }
        if (fileName) {
            this.fileName = fileName;
        }
        if (columnMap) {
            this.columnMap = columnMap;
        }

        this.activeStep++;
    };

    this.previous = () => {
        this.activeStep--;
    };
}
