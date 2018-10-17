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

function surveyOverviewQuestionsController(
    $uibModal,
    surveyService,
    $scope,
    modelsService,
    httpProxy,
    assignedSelectService,
    RequestDeduper,
) {
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
    this.people = [];

    const loadSurveyData = async () => {
        let q = await surveyService.getSurveyQuestions(this.survey.id);
        const requestDeduper = new RequestDeduper();
        this.people = await assignedSelectService.searchPeople(
            '',
            this.survey.organization_id,
            requestDeduper,
        );
        rebuildQuestions(q);
        $scope.$apply();
    };

    const loadPeople = async organizationId => {
        /*    let peopleIds = questions.reduce((a1, q) => {
            return (
                a1 +
                q.question_rules.reduce((a2, r) => {
                    if (!r.people_ids) {
                        return a2;
                    }

                    let separator = a2 ? ',' : '';
                    return a2 + separator + r.people_ids;
                }, '')
            );
        }, ''); */

        var requestDeduper = new RequestDeduper();
        this.people = await assignedSelectService.searchPeople(
            '',
            organizationId,
            requestDeduper,
        );
    };

    const rebuildQuestions = questions => {
        this.surveyQuestions = questions.map(q => buildQuestion(q));
    };

    const buildQuestion = question => {
        let q = question;
        let a = question.content ? question.content.split('\n') : [];
        q.question_answers = a;

        if (question.kind === 'ChoiceField' && a) {
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

                if (!r.people_ids) {
                    return;
                }

                let ids = r.people_ids.split(',');
                ar.assignTo = this.people.filter(p => ids.indexOf(p.id) >= 0);
            }
        });

        return ar;
    };

    this.$onInit = () => {
        loadSurveyData();
    };

    this.addPersonToRule = (question, rule) => {
        let index = question.question_rules.indexOf(rule);

        if (!question.question_rules[index].assignTo) {
            return;
        }

        let ids = [
            ...new Set(question.question_rules[index].assignTo.map(i => i.id)),
        ];
        let currentIds = question.question_rules[index].people_ids
            ? question.question_rules[index].people_ids.split(',')
            : [];

        if (_.isEqual(currentIds.sort(), ids.sort())) {
            return;
        }

        question.question_rules[index].people_ids = ids.join(',');
        this.saveQuestionContent(question, question.question_answers);
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
        if (!question.question_answers) {
            question.question_answers = [];
        }

        question.question_answers.push('');
        question.question_rules.push(
            buildRule('', question.question_rules, 'AUTOASSIGN'),
        );
        question.question_rules.push(
            buildRule('', question.question_rules, 'AUTONOTIFY'),
        );
    };

    this.deleteQuestionContent = async (question, answers, rule, index) => {
        if (rule.id) {
            await surveyService.deleteSurveyQuestionRule(
                this.survey.id,
                rule.id,
            );
            let ruleIndex = question.question_rules.indexOf(rule);
            question.question_rules.splice(ruleIndex, 1);
        }

        question.question_answers.splice(index, 1);
        question.content = answers.join('\n');
        this.saveQuestionContent(question, answers);
    };

    this.saveQuestionContent = async (question, answers) => {
        question.content = answers.join('\n');
        let r = await this.saveQuestion(question);

        if (r.data.question_rules) {
            let index = this.surveyQuestions.indexOf(question);
            this.surveyQuestions[index].question_rules = r.data.question_rules;
        }

        rebuildQuestions(this.surveyQuestions);
        $scope.$apply();
    };
}
