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
        const q = await surveyService.getSurveyQuestions(this.survey.id);
        this.people = await getPeople(q, this.survey.organization_id);
        rebuildQuestions(q);
        $scope.$apply();
    };

    const getPeople = async (questions, organizationId) => {
        const peopleIds = [
            ...new Set(
                questions.reduce((a1, q) => {
                    const ids = q.question_rules.reduce((a2, r) => {
                        return [...a2, ...r.people_ids.split(',')];
                    }, []);
                    return [...a1, ...ids];
                }, []),
            ),
        ];

        const { data } = await httpProxy.get(
            '/people',
            {
                'filters[ids]': peopleIds.join(','),
                'filters[organization_ids]': this.survey.organization_id,
                'fields[people]':
                    'first_name,gender,last_name,primary_email_address,id',
            },
            {
                errorMessage: 'error.messages.surveys.loadQuestions',
            },
        );

        return data;
    };

    const rebuildQuestions = questions => {
        this.surveyQuestions = questions.map(buildQuestion);
    };

    const rebuildQuestion = question => {
        const q = buildQuestion(question);
        const index = this.surveyQuestions.indexOf(question);
        this.surveyQuestions[index] = q;
    };

    const buildQuestion = question => {
        const a = question.content ? question.content.split('\n') : [];

        if (question.kind === 'ChoiceField' && a) {
            const autoassignRules = buildRules(
                question.question_rules,
                a,
                'AUTOASSIGN',
            );
            const autoNotifyRules = buildRules(
                question.question_rules,
                a,
                'AUTONOTIFY',
            );

            return {
                ...question,
                question_answers: a,
                question_rules: [...autoassignRules, ...autoNotifyRules],
            };
        }

        return {
            ...question,
            question_answers: a,
        };
    };

    const buildRules = (questionRules, answerQuestion, type) => {
        return answerQuestion.map(answer =>
            buildRule(answer, questionRules, type),
        );
    };

    const buildRule = (answer, questionRules, type) => {
        const {
            id = null,
            label_ids = null,
            organization_ids = null,
            people_ids = null,
        } =
            questionRules.find(
                r => r.trigger_keywords === answer && r.rule_code === type,
            ) || {};

        const ids = people_ids ? people_ids.split(',') : [];

        return {
            id,
            label_ids,
            organization_ids,
            people_ids,
            rule_code: type,
            trigger_keywords: answer,
            assign_to: id
                ? this.people.filter(p => ids.indexOf(p.id) >= 0)
                : null,
        };
    };

    const buildRulesWithChangedAnswer = (
        question,
        originalAnswer,
        newAnswer,
    ) => {
        return question.question_rules.map(r => {
            if (r.trigger_keywords === originalAnswer) {
                return {
                    ...r,
                    trigger_keywords: newAnswer,
                };
            }
            return r;
        });
    };

    this.$onInit = () => {
        loadSurveyData();
    };

    this.addPersonToRule = async (question, rule) => {
        const index = question.question_rules.indexOf(rule);

        if (!question.question_rules[index].assign_to) {
            return;
        }

        const ids = [
            ...new Set(question.question_rules[index].assign_to.map(a => a.id)),
        ];
        const currentIds = question.question_rules[index].people_ids
            ? question.question_rules[index].people_ids.split(',')
            : [];

        if (_.isEqual(currentIds.sort(), ids.sort())) {
            return;
        }

        question.question_rules[index].people_ids = ids.join(',');
        question.question_rules[index].assign_to.forEach(a => {
            const exists = this.people.find(p => p.id === a.id);
            if (!exists) {
                this.people.push(a);
            }
        });

        await this.saveQuestionContent(question, question.question_answers);
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
                currentQuestions: () => this.surveyQuestions.map(q => q.id),
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
        const {
            id,
            label,
            kind,
            style,
            column_title,
            content,
            notify_via,
        } = question;

        return surveyService.updateSurveyQuestion(
            this.survey.id,
            {
                id,
                label,
                kind,
                style,
                column_title,
                content,
                notify_via,
            },
            question.question_rules,
        );
    };

    this.updateQuestion = async question => {
        await this.saveQuestion(question);
        rebuildQuestion(question);
        $scope.$apply();
    };

    this.addEmptyQuestionContent = question => {
        if (!question.question_answers) question.question_answers = [];

        question.question_answers.push('');
        question.question_rules.push(
            buildRule('', question.question_rules, 'AUTOASSIGN'),
        );
        question.question_rules.push(
            buildRule('', question.question_rules, 'AUTONOTIFY'),
        );
    };

    this.setNotifyVia = (question, via) => {
        question.notify_via = via;
        this.saveQuestionContent(question, question.question_answers);
    };

    this.deleteQuestionContent = async (question, answers, rule, index) => {
        if (rule.id) {
            await surveyService.deleteSurveyQuestionRule(
                this.survey.id,
                rule.id,
            );
            const ruleIndex = question.question_rules.indexOf(rule);
            question.question_rules.splice(ruleIndex, 1);
        }

        question.question_answers.splice(index, 1);
        question.content = answers.join('\n');
        this.saveQuestionContent(question, answers);
    };

    this.updateQuestionAnswer = async (question, answerIndex) => {
        const oldAnswers = question.content.split('\n');
        const newAnswer = question.question_answers[answerIndex];

        const originalAnswer = oldAnswers.find(
            a => question.question_answers.indexOf(a) === -1,
        );

        question.question_rules = buildRulesWithChangedAnswer(
            question,
            originalAnswer,
            newAnswer,
        );

        this.saveQuestionContent(question, question.question_answers);
    };

    this.saveQuestionContent = async (question, answers) => {
        question.content = answers.join('\n');
        const { data } = await this.saveQuestion(question);

        if (data.question_rules) {
            const index = this.surveyQuestions.indexOf(question);
            this.surveyQuestions[index].question_rules = data.question_rules;
        }

        rebuildQuestion(question);
        $scope.$apply();
    };
}
