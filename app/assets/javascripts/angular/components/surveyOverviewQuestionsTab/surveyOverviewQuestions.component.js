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
        { kind: 'TextField', style: 'email', name: 'Email Address' },
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
        { kind: 'DateField', style: 'date_field', name: 'Date', canAdd: true },
    ];

    this.getQuestionType = (kind, style) => {
        return _.find(this.questionTypes, { kind: kind, style: style });
    };

    this.sortableOptions = {
        handle: '.sort',
    };

    this.$onInit = () => {
        surveyService.getSurveyQuestions(this.survey.id).then(questions => {
            this.surveyQuestions = questions;
        });
    };

    this.addPredefinedQuestion = () => {
        $uibModal.open({
            component: 'predefinedQuestionsModal',
            size: 'md',
            resolve: {
                addQuestion: _.constant(question => {
                    this.addQuestion(question);
                }),
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
                this.isExpanded[newQuestion.id] = true;
            });
    };

    this.deleteQuestion = questionId => {
        surveyService
            .deleteSurveyQuestion(this.survey.id, questionId)
            .then(() => {
                _.remove(this.surveyQuestions, { id: questionId });
            });
    };

    this.saveQuestion = _.throttle(
        question => {
            surveyService
                .updateSurveyQuestion(
                    this.survey.id,
                    _.pick(question, [
                        'id',
                        'label',
                        'kind',
                        'style',
                        'column_title',
                        'content',
                    ]),
                )
                .then();
        },
        750,
        { leading: false },
    );

    this.saveQuestionContent = (question, answers) => {
        question.content = answers.join('\n');
        this.saveQuestion(question);
    };
}
