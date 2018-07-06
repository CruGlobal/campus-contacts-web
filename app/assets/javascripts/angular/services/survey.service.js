angular.module('missionhubApp').factory('surveyService', surveyService);

function surveyService(httpProxy, modelsService) {
    var surveyService = {
        // Create a new survey
        createSurvey: function(title, organization) {
            var payload = {
                data: {
                    type: 'survey',
                    attributes: {
                        title: title,
                    },
                    relationships: {
                        organization: {
                            data: {
                                type: 'organization',
                                id: organization,
                            },
                        },
                    },
                },
            };

            return httpProxy
                .post(
                    modelsService.getModelMetadata('survey').url.all,
                    payload,
                    {
                        errorMessage: 'surveyTab:errors.createSurvey',
                    },
                )
                .then(function(survey) {
                    return survey.data;
                });
        },

        updateSurvey: survey => {
            return httpProxy
                .post(
                    modelsService
                        .getModelMetadata('survey')
                        .url.single(survey.id),
                    {
                        data: {
                            type: 'survey',
                            attributes: {
                                title: survey.title,
                                is_frozen: survey.is_frozen,
                            },
                        },
                    },
                    {
                        errorMessage: 'surveyTab:errors.updateSurvey',
                    },
                )
                .then(function(survey) {
                    return survey.data;
                });
        },

        deleteSurvey: survey => {
            return httpProxy.delete(
                modelsService.getModelMetadata('survey').url.single(survey.id),
                null,
                {
                    errorMessage: 'surveyTab:errors.deleteSurvey',
                },
            );
        },
    };

    return surveyService;
}
