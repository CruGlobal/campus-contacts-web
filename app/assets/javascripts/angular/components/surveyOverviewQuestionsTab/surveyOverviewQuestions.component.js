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

function surveyOverviewQuestionsController(surveyService) {
    this.icons = {
        copy: copyIcon,
        help: helpIcon,
        sort: sortIcon,
        trash: trashIcon,
        xWhite: xWhiteIcon,
    };

    this.questionTypes = [
        { kind: 'TextField', style: 'short', name: 'Short Answer' },
        { kind: 'ChoiceField', style: 'radio', name: 'Radio (Choose one)' },
        {
            kind: 'ChoiceField',
            style: 'checkbox',
            name: 'Checkbox (Choose one or more)',
        },
        {
            kind: 'ChoiceField',
            style: 'drop-down',
            name: 'Dropdown (Choose one)',
        },
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

        surveyService.getPredefinedQuestions().then(questions => {
            this.predefinedQuestions = questions;
        });
    };

    this.addQuestion = question => {
        surveyService
            .createSurveyQuestion(this.survey.id, question)
            .then(newQuestion => {
                this.surveyQuestions.push(newQuestion);
            });
    };

    this.deleteQuestion = questionId => {
        surveyService
            .deleteSurveyQuestion(this.survey.id, questionId)
            .then(() => {
                _.remove(this.surveyQuestions, { id: questionId });
            });
    };
}
