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
    this.$onInit = () => {
        this.answers = {};

        surveyService
            .getSurveyQuestions(this.resolve.survey.id)
            .then(questions => {
                this.surveyQuestions = questions;
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
            postData.included.push({
                type: 'answer',
                attributes: {
                    question_id: Number(id),
                    value: this.answers[id],
                },
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
