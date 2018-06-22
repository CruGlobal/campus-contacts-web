angular.module('missionhubApp').factory('surveyService', surveyService);

function surveyService(
    httpProxy,
    modelsService,
) {
    var surveyService = {
        // Create a new survey
        createSurvey: function(title, organization) {
            var payload = {
                data: {
                    type: 'survey',
                    attributes: {
                        title: title,
                        post_survey_message: title
                    },
                    relationships: {
                        organization: {
                            data: {
                                type: 'organization',
                                id: organization
                            }
                        }
                    }
                }
            };

            return httpProxy
                .post(
                    modelsService.getModelMetadata('survey').url.all,
                    payload,
                    {
                        errorMessage: 'error.messages.surveys.create_survey',
                    },
                )
                .then(function(survey) {
                    return survey.data;
                });
        },
    };

    return surveyService;
}
