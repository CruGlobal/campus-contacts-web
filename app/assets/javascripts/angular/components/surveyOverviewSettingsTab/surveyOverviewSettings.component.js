import template from './surveyOverviewSettings.html';
import _ from 'lodash';

angular.module('missionhubApp').component('surveyOverviewSettings', {
    controller: surveyOverviewSettingsController,
    bindings: {
        survey: '<',
    },
    template: template,
});

function surveyOverviewSettingsController($scope, surveyService) {
    const saveSurvey = _.throttle(
        (newSurveyData, oldSurveyData) => {
            if (angular.equals(newSurveyData, oldSurveyData)) {
                return;
            }

            this.survey.title = this.surveyEdit.title;
            this.survey.welcome_message = this.surveyEdit.welcome_message;
            this.survey.post_survey_message = this.surveyEdit.post_survey_message;

            //only send logo if updated
            if (this.surveyEdit.logo !== this.survey.logo_url) {
                this.survey.logo = this.surveyEdit.logo;
            }

            surveyService.updateSurvey(this.survey);
        },
        1500,
        { leading: false },
    );

    this.$onInit = () => {
        this.surveyEdit = {
            title: this.survey.title,
            welcome_message: this.survey.welcome_message,
            post_survey_message: this.survey.post_survey_message,
            logo: this.survey.logo_url,
        };

        $scope.$watch(
            () => {
                return this.surveyEdit;
            },
            saveSurvey,
            true,
        );
    };

    this.selectImage = () => {
        // eslint-disable-next-line angular/document-service
        const input = document.createElement('input');
        input.setAttribute('type', 'file');
        input.click();

        input.addEventListener(
            'change',
            () => {
                this.selectedImage = input.files[0];

                //validate type
                if (
                    !_.includes(
                        ['image/jpeg', 'image/png'],
                        this.selectedImage.type,
                    )
                ) {
                    return;
                }

                //base 64 encode image
                const reader = new FileReader();
                reader.onload = event => {
                    this.surveyEdit.logo = event.target.result;
                    $scope.$digest();
                };
                reader.readAsDataURL(this.selectedImage);
            },
            false,
        );
    };
}
