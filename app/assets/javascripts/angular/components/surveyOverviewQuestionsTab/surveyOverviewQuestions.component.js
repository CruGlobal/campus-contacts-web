import template from './surveyOverviewQuestions.html';
import _ from 'lodash';
import { t } from 'i18next';

import copyIcon from '../../../../images/icons/icon-copy.svg';
import sortIcon from '../../../../images/icons/icon-sort.svg';
import trashIcon from '../../../../images/icons/icon-trash.svg';
import helpIcon from '../../../../images/icons/icon-help.svg';
import xWhiteIcon from '../../../../images/icons/icon-x-white.svg';
import warningIcon from '../../../../images/icons/icon-warning-2.svg';

angular.module('missionhubApp').component('surveyOverviewQuestions', {
    controller: surveyOverviewQuestionsController,
    bindings: {
        survey: '<',
    },
    template: template,
});

function surveyOverviewQuestionsController($uibModal, surveyService, $scope) {
    this.isExpanded = {};
    this.surveyQuestions = [];
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

    const loadSurveyData = async () => {
        let data = await surveyService.getSurveyQuestions(this.survey.id);
        rebuildQuestions(data);
        $scope.$apply();
    };

    const rebuildQuestions = questions => {
        this.surveyQuestions = questions.map(q => buildQuestion(q));
    };

    const buildQuestion = question => {
        let q = question;
        let a = question.content ? question.content.split('\n') : [];
        q.question_answers = a;

        if (question.kind === 'ChoiceField') {
            let autoassignRules = buildRules(
                question.question_rules,
                a,
                'AUTOASSIGN',
            );
            let autoNotifyRules = buildRules(
                question.question_rules,
                a,
                'AUTONOTIFY',
            );

            q.question_rules = autoassignRules.concat(autoNotifyRules);
        }

        return q;
    };

    const buildRules = (questionRules, answerQuestion, type) => {
        return answerQuestion.map(answer =>
            buildRule(answer, questionRules, type),
        );
    };

    const buildRule = (answer, questionRules, type) => {
        let ar = {
            id: null,
            label_ids: null,
            organization_ids: null,
            people_ids: null,
            rule_code: type,
            trigger_keywords: answer,
            assign_to: null,
        };

        questionRules.forEach(r => {
            if (r.trigger_keywords === answer && r.rule_code === type) {
                ar.id = r.id;
                ar.label_ids = r.label_ids;
                ar.organization_ids = r.organization_ids;
                ar.people_ids = r.people_ids;
                ar.trigger_keywords = r.trigger_keywords;
            }
        });

        return ar;
    };

    this.$onInit = () => {
        loadSurveyData();
    };

    this.addPersonToRule = (question, index) => {
        if (question.question_rules[index].assignTo) {
            let ids = [];
            question.question_rules[index].assignTo.forEach(a => {
                ids.push(a.id);
            });
            question.question_rules[index].people_ids = ids.join(',');
            this.saveQuestionContent(question, question.question_answers);
        }
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
                component: 'iconModal',
                resolve: {
                    icon: () => warningIcon,
                    paragraphs: () => [t('surveys:questions.delete_confirm')],
                    dismissLabel: () => t('cancel'),
                    closeLabel: () => t('general.delete'),
                },
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

        return surveyService.updateSurveyQuestion(
            this.survey.id,
            {
                id,
                label,
                kind,
                style,
                column_title,
                content,
            },
            question.question_rules,
        );
    };

    this.addEmptyQuestionContent = question => {
        question.question_answers.push('');
        question.question_rules.push(
            buildRule('', question.question_rules, 'AUTOASSIGN'),
        );
        question.question_rules.push(
            buildRule('', question.question_rules, 'AUTONOTIFY'),
        );
    };

    this.deleteQuestionContent = async (question, answers, index) => {
        question.question_answers.splice(index, 1);
        question.content = answers.join('\n');
        this.saveQuestionContent(question, answers);
    };

    this.saveQuestionContent = async (question, answers) => {
        question.content = answers.join('\n');
        await this.saveQuestion(question);
        rebuildQuestions(this.surveyQuestions);
        $scope.$apply();
    };
}
