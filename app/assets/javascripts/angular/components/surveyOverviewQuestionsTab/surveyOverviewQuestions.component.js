import template from './surveyOverviewQuestions.html';
import _ from 'lodash';

import copyIcon from '../../../../images/icons/icon-copy.svg';
import sortIcon from '../../../../images/icons/icon-sort.svg';
import trashIcon from '../../../../images/icons/icon-trash.svg';
import helpIcon from '../../../../images/icons/icon-help.svg';
import xWhiteIcon from '../../../../images/icons/icon-x-white.svg';

angular.module('missionhubApp').component('surveyOverviewQuestions', {
    controller: surveyOverviewQuestionsController,
    bindings: {
        survey: '<',
    },
    template: template,
});

function surveyOverviewQuestionsController($uibModal, surveyService) {
    this.isExpanded = {};

    this.icons = {
        copy: copyIcon,
        help: helpIcon,
        sort: sortIcon,
        trash: trashIcon,
        xWhite: xWhiteIcon,
    };

    this.questionTypes = [
        {
            kind: 'TextField',
            style: 'short',
            name: 'Short Answer',
            canAdd: true,
        },
        {
            kind: 'TextField',
            style: 'email',
            name: 'Email Address',
        },
        {
            kind: 'ChoiceField',
            style: 'radio',
            name: 'Radio (Choose one)',
            canAdd: true,
        },
        {
            kind: 'ChoiceField',
            style: 'checkbox',
            name: 'Checkbox (Choose one or more)',
            canAdd: true,
        },
        {
            kind: 'ChoiceField',
            style: 'drop-down',
            name: 'Dropdown (Choose one)',
            canAdd: true,
        },
        {
            kind: 'DateField',
            style: 'date_field',
            name: 'Date',
        },
    ];

    this.$onInit = () => {
        surveyService.getSurveyQuestions(this.survey.id).then(questions => {
            this.surveyQuestions = questions;
        });
    };

    this.getQuestionType = (kind, style) => {
        return _.find(this.questionTypes, { kind: kind, style: style });
    };

    this.sortableOptions = {
        handle: '.sort',
    };

    this.addPredefinedQuestion = () => {
        $uibModal.open({
            component: 'predefinedQuestionsModal',
            size: 'md',
            resolve: {
                currentQuestions: () =>
                    this.surveyQuestions.map(question => question.id),
                addQuestion: () => question => {
                    this.addQuestion(question);
                },
            },
        });
    };

    this.addQuestion = question => {
        if (!question.content) {
            question.content = '';
        }

        surveyService
            .createSurveyQuestion(this.survey.id, question)
            .then(newQuestion => {
                this.surveyQuestions.push(newQuestion);

                if (!newQuestion.predefined) {
                    this.isExpanded[newQuestion.id] = true;
                }
            });
    };

    this.copyQuestion = question => {
        this.addQuestion(_.omit(question, ['id']));
    };

    this.deleteQuestion = questionId => {
        $uibModal
            .open({
                component: 'deleteQuestionConfirmModal',
                size: 'md',
            })
            .result.then(() => {
                surveyService
                    .deleteSurveyQuestion(this.survey.id, questionId)
                    .then(() => {
                        _.remove(this.surveyQuestions, { id: questionId });
                    });
            });
    };

    this.saveQuestion = question => {
        let { id, label, kind, style, column_title, content } = question;

        return surveyService.updateSurveyQuestion(this.survey.id, {
            id,
            label,
            kind,
            style,
            column_title,
            content,
        });
    };

    this.deleteQuestionContent = async (question, answers, index) => {
        answers.splice(index, 1);
        question.content = answers.join('\n');
        await this.saveQuestion(question);
    };

    this.saveQuestionContent = async (question, answers) => {
        question.content = answers.join('\n');
        await this.saveQuestion(question);
    };
}
