import _ from 'lodash';
import i18next from 'i18next';

import './surveyFormPublic.scss';

import surveyFormUserTemplate from './surveyFormUser.html';
import surveyFormPublicTemplate from './surveyFormPublic.html';

const bindings = {
    survey: '<',
    onInit: '&',
    onSavingChange: '&',
    onSuccess: '&',
};

// Note: angularjs-annotate doesn't work if you try move the controller part of the component config to a shared object

angular
    .module('missionhubApp')
    .component('surveyFormUser', {
        controller: surveyFormController,
        bindings,
        template: surveyFormUserTemplate,
    })
    .component('surveyFormPublic', {
        controller: surveyFormController,
        bindings,
        template: surveyFormPublicTemplate,
    });

function surveyFormController($window, surveyService) {
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
                name: i18next.t('select'),
            });
        }

        return choices;
    };

    this.$onInit = () => {
        this.onInit({ $event: { save: this.save } });
        this.answers = {};
        this.questionChoices = {};

        surveyService.getSurveyQuestions(this.survey.id).then(questions => {
            this.surveyQuestions = questions.data;
            _.forEach(questions.data, question => {
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
        this.onSavingChange({ $event: true });

        let postData = {
            data: {
                type: 'answer_sheet',
                attributes: {},
                relationships: {
                    survey: {
                        data: {
                            type: 'survey',
                            id: this.survey.id,
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
                    this.onSavingChange({ $event: false });
                } else {
                    this.onSuccess();
                }
            },
            response => {
                const {
                    data: { errors: [{ detail: details } = {}] = [] } = {},
                } = response;
                this.importError = details;
                $window.scrollTo(0, 0);
                this.onSavingChange({ $event: false });
            },
        );
    };
}
