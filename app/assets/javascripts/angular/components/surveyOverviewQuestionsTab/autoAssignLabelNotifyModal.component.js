import template from './autoAssignLabelNotifyModal.html';
import './autoAssignLabelNotifyModal.scss';

angular.module('missionhubApp').component('autoAssignLabelNotifyModal', {
    controller: autoAssignLabelNotifyModalController,
    template: template,
    bindings: {
        resolve: '<',
        close: '&',
        dismiss: '&',
    },
});

function autoAssignLabelNotifyModalController() {
    this.$onInit = () => {
        this.survey = this.resolve.survey;
        this.question = this.resolve.question;
        this.answer = this.resolve.answer;
        this.assignRule = this.question.question_rules.find(
            rule =>
                rule.trigger_keywords === this.answer &&
                rule.rule_code === 'AUTOASSIGN',
        );
        this.notifyRule = this.question.question_rules.find(
            rule =>
                rule.trigger_keywords === this.answer &&
                rule.rule_code === 'AUTONOTIFY',
        );
        this.addPersonToRule = this.resolve.addPersonToRule;
        this.addLabelToRule = this.resolve.addLabelToRule;
    };
}
