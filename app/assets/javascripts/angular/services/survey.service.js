function surveyService(
    envService,
    $q,
    $http,
    httpProxy,
    modelsService,
    loggedInPerson,
    periodService,
    $log,
) {
    return {
        getSurveyQuestions: surveyId => {
            return $q
                .all([
                    httpProxy.get(
                        '/surveys/predefined',
                        {
                            include: 'active_survey_elements.question',
                        },
                        {
                            errorMessage:
                                'error.messages.surveys.loadQuestions',
                        },
                    ),
                    httpProxy.get(
                        `/surveys/${surveyId}/questions`,
                        {
                            include: 'question_rules',
                        },
                        {
                            errorMessage:
                                'error.messages.surveys.loadQuestions',
                        },
                    ),
                ])
                .then(([predefinedSurvey, surveyQuestions]) => {
                    let predefinedQuestions = predefinedSurvey.data.active_survey_elements.map(
                        element => element.question,
                    );

                    //only include hard coded predefined questions (first/last name and phone)
                    predefinedQuestions = predefinedQuestions.filter(question =>
                        _.includes(['3457', '3458', '17'], question.id),
                    );

                    return [...predefinedQuestions, ...surveyQuestions.data];
                });
        },

        getPredefinedQuestions: () => {
            return httpProxy
                .get(
                    '/surveys/predefined',
                    {
                        include: 'active_survey_elements.question',
                    },
                    {
                        errorMessage: 'error.messages.surveys.loadQuestions',
                    },
                )
                .then(predefinedQuestions => {
                    return predefinedQuestions.data.active_survey_elements.map(
                        element => element.question,
                    );
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

        createSurveyQuestion: (surveyId, attributes) => {
            const isPredefinedQuestion = !!attributes.id;
            const payload = isPredefinedQuestion
                ? {
                      data: {
                          type: 'question',
                          id: attributes.id,
                      },
                  }
                : {
                      data: {
                          type: 'question',
                          attributes: attributes,
                      },
                  };

            return isPredefinedQuestion
                ? httpProxy
                      .put(
                          `/surveys/${surveyId}/questions/${attributes.id}`,
                          payload,
                          {
                              errorMessage: 'surveyTab:errors.createSurvey',
                          },
                      )
                      .then(survey => {
                          return survey.data;
                      })
                : httpProxy
                      .post(`/surveys/${surveyId}/questions`, payload, {
                          errorMessage: 'surveyTab:errors.createSurvey',
                      })
                      .then(survey => {
                          return survey.data;
                      });
        },

        updateSurveyQuestion: (surveyId, attributes, rules) => {
            let payload = {
                data: {
                    type: 'question',
                    attributes: attributes,
                },
            };

            if (rules) {
                let ruleRelationship = [];
                let ruleIncludes = [];

                rules.forEach(r => {
                    if (r.id) {
                        ruleRelationship.push({
                            type: 'question_rule',
                            id: r.id,
                        });
                    }

                    if (!r.people_ids || r.people_ids === '') {
                        return;
                    }

                    if (!r.trigger_keywords || r.trigger_keywords === '') {
                        return;
                    }

                    ruleIncludes.push({
                        id: r.id,
                        type: 'question_rule',
                        attributes: {
                            label_ids: null,
                            organization_ids: null,
                            people_ids: r.people_ids,
                            rule_code: r.rule_code,
                            trigger_keywords: r.trigger_keywords,
                        },
                    });
                });

                payload.data.relationships = {
                    question_rules: {
                        data: ruleRelationship,
                    },
                };

                payload.included = ruleIncludes;
            }

            return httpProxy.put(
                `/surveys/${surveyId}/questions/${attributes.id}`,
                payload,
                {
                    errorMessage: 'surveyTab:errors.createSurvey',
                },
            );
        },

        deleteSurveyQuestion: (surveyId, questionId) => {
            return httpProxy.delete(
                `/surveys/${surveyId}/questions/${questionId}`,
                null,
                {
                    errorMessage: 'surveyTab:errors.createSurvey',
                },
            );
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
                                ...(survey.logo === undefined
                                    ? {}
                                    : { logo: survey.logo }), // Only send logo field to API when it is a base64 string or null (to allow deletion)
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

        copySurvey: (surveyId, org, title) => {
            return httpProxy.post(
                `/surveys/${surveyId}/copy`,
                {
                    data: {
                        type: 'survey',
                        attributes: {
                            parent_organization: org,
                            title: title,
                        },
                    },
                },
                {
                    errorMessage: 'surveyTab:errors.createSurvey',
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

        updateKeyword: data => {
            const payload = {
                data: {
                    type: 'sms_keyword',
                    attributes: {
                        initial_response: data.keyword.initial_response,
                    },
                },
            };

            return httpProxy
                .put(
                    modelsService
                        .getModelMetadata('sms_keyword')
                        .url.single(data.keyword.id),
                    payload,
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
                .then(httpProxy.extractModels);
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

        importAnswerSheet: payload => {
            return httpProxy
                .post(
                    modelsService.getModelMetadata('answer_sheet').url.all,
                    payload,
                    {
                        errorMessage: 'contact_import:errors.save',
                        params: {
                            include: 'person',
                        },
                    },
                )
                .then(httpProxy.extractModels);
        },
    };
}

angular.module('missionhubApp').factory('surveyService', surveyService);
