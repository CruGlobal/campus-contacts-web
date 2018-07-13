angular.module('missionhubApp').factory('surveyService', surveyService);

function surveyService(httpProxy, modelsService, loggedInPerson) {
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
                .put(
                    modelsService
                        .getModelMetadata('survey')
                        .url.single(survey.id),
                    {
                        data: {
                            type: 'survey',
                            attributes: {
                                title: survey.title,
                                is_frozen: survey.is_frozen,
                                post_survey_message: survey.post_survey_message,
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

        deleteKeyword: keywordId => {
            return httpProxy.delete(
                modelsService
                    .getModelMetadata('sms_keyword')
                    .url.single(keywordId),
                null,
                {
                    errorMessage: 'surveys:keyword:errors.deleteKeyword',
                },
            );
        },

        requestKeyword: data => {
            const payload = {
                data: {
                    type: 'sms_keyword',
                    attributes: {
                        state: 'requested',
                        user_id: loggedInPerson.person.user.id,
                        keyword: data.keyword.keyword,
                        initial_response: data.keyword.initial_response,
                        explanation: data.keyword.explanation,
                        survey_id: data.surveyId,
                        organization_id: data.orgId,
                    },
                },
            };

            return httpProxy
                .post(
                    modelsService.getModelMetadata('sms_keyword').url.all,
                    payload,
                    {
                        errorMessage: 'surveys:keyword:errors.requestKeyword',
                    },
                )
                .then(function(keyword) {
                    return keyword.data;
                });
        },
    };

    return surveyService;
}
