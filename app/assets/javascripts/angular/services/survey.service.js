function surveyService(
    envService,
    $q,
    $http,
    httpProxy,
    modelsService,
    loggedInPerson,
    periodService,
) {
    return {
        getSurveyQuestions: surveyId => {
            return $q
                .all([
                    $http.get(
                        envService.read('apiUrl') + '/surveys/predefined',
                        {
                            params: {
                                include: 'active_survey_elements.question',
                            },
                        },
                    ),
                    $http.get(
                        envService.read('apiUrl') +
                            '/surveys/' +
                            surveyId +
                            '/questions',
                    ),
                ])
                .then(questions => {
                    const predefinedQuestions = questions[0].data.included;
                    const predefinedQuestionIds = predefinedQuestions.map(
                        question => question.id,
                    );
                    const surveyQuestions = questions[1].data.data.filter(
                        question => {
                            return !predefinedQuestionIds.includes(question.id);
                        },
                    );

                    return predefinedQuestions.concat(surveyQuestions);
                });
        },

        // Create a new survey
        createSurvey: (title, organization) => {
            const payload = {
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
                .then(survey => {
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
                                login_paragraph: survey.login_paragraph,
                                logo: survey.logo,
                            },
                        },
                    },
                    {
                        errorMessage: 'surveyTab:errors.updateSurvey',
                    },
                )
                .then(survey => {
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

        getStats: surveyId => {
            return httpProxy
                .get(
                    modelsService.getModelMetadata('survey_report').url.all,
                    {
                        period: periodService.getPeriod(),
                        survey_id: surveyId.toString(),
                    },
                    {
                        errorMessage: 'surveyTab:errors.getStats',
                    },
                )
                .then(httpProxy.extractModels)
                .then(function(survey) {
                    return survey[0];
                });
        },

        importContacts: payload => {
            return httpProxy
                .post(
                    modelsService.getModelMetadata('bulk_create_job').url.all,
                    payload,
                    {
                        errorMessage: 'contact_import:errors.bulkImport',
                    },
                )
                .then(httpProxy.extractModels);
        },
    };
}

angular.module('missionhubApp').factory('surveyService', surveyService);
