import template from './surveyOverviewKeyword.html';
import _ from 'lodash';

import helpIcon from '../../../../images/icon-help.svg';

angular.module('missionhubApp').component('surveyOverviewKeyword', {
    controller: surveyOverviewKeywordController,
    bindings: {
        survey: '<',
    },
    template: template,
});

function surveyOverviewKeywordController($scope, $uibModal, surveyService) {
    this.helpIcon = helpIcon;

    this.$onInit = () => {
        this.keyword = angular.copy(this.survey.keyword) || {};

        this.disableKeywordField =
            this.keyword.keyword &&
            _.includes(['requested', 'active'], this.keyword.state);
    };

    this.requestKeyword = () => {
        this.keywordError = false;

        surveyService
            .requestKeyword({
                surveyId: this.survey.id,
                orgId: this.survey.organization_id,
                keyword: this.keyword,
            })
            .then(
                keywordData => {
                    this.keyword = keywordData;

                    $uibModal.open({
                        component: 'keywordRequestModal',
                        size: 'md',
                    });
                },
                () => {
                    this.keywordError = true;
                },
            );
    };

    this.deleteKeyword = keywordId => {
        this.survey.keyword = {};
        this.keyword = {};
        surveyService.deleteKeyword(keywordId);
    };
}
