import template from './addSurveyResponseModal.html';
import _ from 'lodash';

import './addSurveyResponseModal.scss';

angular.module('missionhubApp').component('addSurveyResponseModal', {
    controller: addSurveyResponseController,
    bindings: {
        resolve: '<',
        dismiss: '&',
        close: '&',
    },
    template: template,
});
function addSurveyResponseController(surveyService) {
    const getChoices = (content, includeEmptyOption) => {
        let choices = content.split('\n');

        choices = _.map(choices, choice => {
            return {
                value: choice,
                name: choice,
            };
        });

        //add undefined option
        if (includeEmptyOption) {
            choices.unshift({
                name: '-',
            });
        }

        return choices;
    };

    this.$onInit = () => {
        this.answers = {};
        this.questionChoices = {};

        surveyService
            .getSurveyQuestions(this.resolve.survey.id)
            .then(questions => {
                this.surveyQuestions = questions;
                _.forEach(questions, question => {
                    if (question.content) {
                        this.questionChoices[question.id] = getChoices(
                            question.content,
                            question.style === 'drop-down',
                        );
                    }
                });
            });
    };

    this.save = addAnother => {
        delete this.importError;
        this.saving = true;

        let postData = {
            data: {
                type: 'answer_sheet',
                attributes: {},
                relationships: {
                    survey: {
                        data: {
                            type: 'survey',
                            id: this.resolve.survey.id,
                        },
                    },
                },
            },
            included: [],
        };

        _.forEach(_.keys(this.answers), id => {
            let answer = this.answers[id];

            if (_.isObject(answer)) {
                //checkbox answers
                answer = _.keys(_.pickBy(answer, _.identity));
            } else {
                answer = [answer];
            }

            _.forEach(answer, answer => {
                postData.included.push({
                    type: 'answer',
                    attributes: {
                        question_id: Number(id),
                        value: answer,
                    },
                });
            });
        });

        surveyService.importAnswerSheet(postData).then(
            () => {
                if (addAnother) {
                    this.answers = {};
                    this.saving = false;
                } else {
                    this.close();
                }
            },
            response => {
                const {
                    data: { errors: [{ detail: details } = {}] = [] } = {},
                } = response;
                this.importError = details;
                this.saving = false;
            },
        );
    };
}
