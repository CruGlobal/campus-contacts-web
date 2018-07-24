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
    const vm = this;

    const saveSurvey = _.throttle(
        (newSurveyData, oldSurveyData) => {
            if (angular.equals(newSurveyData, oldSurveyData)) {
                return;
            }

            vm.survey.title = vm.surveyEdit.title;
            vm.survey.welcome_message = vm.surveyEdit.welcome_message;
            vm.survey.post_survey_message = vm.surveyEdit.post_survey_message;

            //only send logo if updated
            if (vm.surveyEdit.logo !== vm.survey.logo_url) {
                vm.survey.logo = vm.surveyEdit.logo;
            }

            surveyService.updateSurvey(vm.survey);
        },
        1500,
        { leading: false },
    );

    vm.$onInit = () => {
        vm.surveyEdit = {
            title: vm.survey.title,
            welcome_message: vm.survey.welcome_message,
            post_survey_message: vm.survey.post_survey_message,
            logo: vm.survey.logo_url,
        };

        $scope.$watch(
            () => {
                return vm.surveyEdit;
            },
            saveSurvey,
            true,
        );
    };

    vm.selectImage = () => {
        // eslint-disable-next-line
        const input = document.createElement('input');
        input.setAttribute('type', 'file');
        input.click();

        input.addEventListener(
            'change',
            () => {
                vm.selectedImage = input.files[0];

                //validate type
                if (
                    !_.includes(
                        ['image/jpeg', 'image/png'],
                        vm.selectedImage.type,
                    )
                ) {
                    return;
                }

                //base 64 encode image
                const reader = new FileReader();
                reader.onload = event => {
                    vm.surveyEdit.logo = event.target.result;
                    $scope.$digest();
                };
                reader.readAsDataURL(vm.selectedImage);
            },
            false,
        );
    };
}
