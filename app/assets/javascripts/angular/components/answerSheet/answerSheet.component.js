import moment from 'moment';

import template from './answerSheet.html';
import './answerSheet.scss';

angular.module('missionhubApp').component('answerSheet', {
    template: template,
    bindings: {
        answerSheet: '<',
        organizationId: '<',
    },
    controller: answerSheetController,
});

function answerSheetController($uibModal, loggedInPerson) {
    this.moment = moment;

    this.editResponse = () => {
        $uibModal.open({
            component: 'editAnswerSheetModal',
            resolve: {
                answerSheet: () => this.answerSheet,
                organizationId: () => this.organizationId,
            },
            windowClass: 'pivot_theme',
            backdrop: 'static',
            keyboard: false,
        });
    };

    this.$onInit = () => {
        this.directAdminPrivileges = loggedInPerson.isDirectAdminAt(
            this.answerSheet.survey.organization,
        );
    };
}
