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

function surveyOverviewKeywordController(
    $scope,
    $uibModal,
    surveyService,
    confirmModalService,
    tFilter,
) {
    this.helpIcon = helpIcon;

    this.$onInit = () => {
        this.keyword = angular.copy(this.survey.keyword) || {};

        this.disableKeywordField =
            this.keyword.keyword &&
            _.includes(['requested', 'active'], this.keyword.state);
    };

    this.requestKeyword = () => {
        this.keywordError = '';
        if (!this.keyword.keyword) {
            this.keywordError = tFilter(
                'surveys:keyword:errors:missingKeyword',
            );
        } else if (!this.keyword.explanation) {
            this.keywordError = tFilter(
                'surveys:keyword:errors:missingPurpose',
            );
        } else if (!this.keyword.initial_response) {
            this.keywordError = tFilter(
                'surveys:keyword:errors:missingTextResponse',
            );
        }

        if (this.keywordError) {
            return;
        }

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
                response => {
                    const {
                        data: { errors: [{ detail: details } = {}] = [] } = {},
                    } = response;

                    //display first error
                    this.keywordError = details[_.keys(details)[0]][0];
                },
            );
    };

    this.deleteKeyword = keywordId => {
        confirmModalService
            .create(tFilter('surveys:keyword:delete:confirm'))
            .then(() => {
                this.survey.keyword = {};
                this.keyword = {};
                surveyService.deleteKeyword(keywordId);
            });
    };
}
