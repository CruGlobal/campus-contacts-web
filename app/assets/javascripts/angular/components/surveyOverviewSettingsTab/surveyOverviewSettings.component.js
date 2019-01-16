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
    loggedInPerson,
) {
    this.saveSurvey = _.throttle(
        () => {
            if (!this.directAdminPrivileges) return;

            this.survey.title = this.surveyEdit.title;
            this.survey.login_paragraph = this.surveyEdit.login_paragraph;
            this.survey.post_survey_message = this.surveyEdit.post_survey_message;
            this.survey.logo = this.surveyEdit.logo;
            this.survey.validate_phone_number = this.surveyEdit.validate_phone_number;
            this.survey.validation_message = this.surveyEdit.validation_message;
            this.survey.validation_success_message = this.surveyEdit.validation_success_message;

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
        this.directAdminPrivileges = loggedInPerson.isDirectAdminAt(
            this.survey.organization,
        );

        this.surveyEdit = {
            title: this.survey.title,
            login_paragraph: this.survey.login_paragraph,
            post_survey_message: this.survey.post_survey_message,
            logo_url: this.survey.logo_url,
            validate_phone_number: this.survey.validate_phone_number,
            validation_message: this.survey.validation_message,
            validation_success_message: this.survey.validation_success_message,
        };
    };

    this.selectImage = () => {
        if (!this.directAdminPrivileges) return;

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
        if (!this.directAdminPrivileges) return;

        confirmModalService
            .create(tFilter('surveys:settings:image_delete_confirm'))
            .then(() => {
                this.surveyEdit.logo_url = null;
                this.surveyEdit.logo = null;
                this.saveSurvey();
            });
    };
}
