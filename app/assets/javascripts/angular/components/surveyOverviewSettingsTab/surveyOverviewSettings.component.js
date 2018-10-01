import template from './surveyOverviewSettings.html';
import _ from 'lodash';

angular.module('missionhubApp').component('surveyOverviewSettings', {
    controller: surveyOverviewSettingsController,
    bindings: {
        survey: '<',
    },
    template: template,
});

function surveyOverviewSettingsController(
    surveyService,
    confirmModalService,
    tFilter,
) {
    this.saveSurvey = _.throttle(
        () => {
            this.survey.title = this.surveyEdit.title;
            this.survey.login_paragraph = this.surveyEdit.login_paragraph;
            this.survey.post_survey_message = this.surveyEdit.post_survey_message;
            this.survey.logo = this.surveyEdit.logo;

            surveyService.updateSurvey(this.survey).then(updatedSurveyData => {
                // clear logo base64 data after upload
                delete this.surveyEdit.logo;
                this.surveyEdit.logo_url = updatedSurveyData.logo_url;
            });
        },
        1500,
        { leading: false },
    );

    this.$onInit = () => {
        this.surveyEdit = {
            title: this.survey.title,
            login_paragraph: this.survey.login_paragraph,
            post_survey_message: this.survey.post_survey_message,
            logo_url: this.survey.logo_url,
        };
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

                //clear current logo
                this.surveyEdit.logo_url = null;

                //base 64 encode image
                const reader = new FileReader();
                reader.onload = event => {
                    this.surveyEdit.logo = event.target.result;
                    this.saveSurvey();
                };
                reader.readAsDataURL(this.selectedImage);
            },
            false,
        );
    };

    this.deleteImage = () => {
        confirmModalService
            .create(tFilter('surveys:settings:image_delete_confirm'))
            .then(() => {
                this.surveyEdit.logo_url = null;
                this.surveyEdit.logo = null;
                this.saveSurvey();
            });
    };
}
