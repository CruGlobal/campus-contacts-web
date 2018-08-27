import template from './copySurvey.html';

angular.module('missionhubApp').component('copySurvey', {
    controller: copySurveyController,
    bindings: {
        resolve: '<',
        close: '&',
        dismiss: '&',
    },
    template: template,
});

function copySurveyController(surveyService, loggedInPerson) {
    this.saving = false;
    this.survey = {};

    this.$onInit = () => {
        this.survey.id = this.resolve.survey.id;
        this.survey.title = this.resolve.survey.title;

        this.orgs = loggedInPerson.person.organizational_permissions.map(
            orgPermission => orgPermission.organization,
        );
        this.orgs = this.orgs.filter(org => {
            return loggedInPerson.isAdminAt(org);
        });

        //default to current org
        this.survey.parent_organization = this.resolve.organizationId;
    };

    this.valid = () => {
        return this.survey.parent_organization && this.survey.title;
    };

    this.save = () => {
        this.saving = true;

        surveyService
            .copySurvey(
                this.survey.id,
                this.survey.parent_organization,
                this.survey.title,
            )
            .then(
                newSurvey => {
                    this.close(newSurvey);
                },
                response => {
                    this.saving = false;
                    this.error = response.data.error;
                },
            );
    };
}
