import _ from 'lodash';
import i18next from 'i18next';

import helpIcon from '../../../../images/icon-help.svg';
import clockIcon from '../../../../images/icon-clock.svg';

import template from './surveyOverviewKeyword.html';

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
    loggedInPerson,
) {
    this.helpIcon = helpIcon;
    this.hasChanged = false;

    const keywordErrorHandler = response => {
        let {
            data: { errors: [{ detail: details } = {}] = [] } = {},
        } = response;

        if (angular.isString(details)) {
            this.keywordError = details;
        } else if (angular.isObject(details)) {
            //display first error
            details = Object.values(details);
            if (details.length && details[0].length) {
                this.keywordError = details[0][0];
            }
        }
    };

    this.$onInit = () => {
        this.directAdminPrivileges = loggedInPerson.isDirectAdminAt(
            this.survey.organization,
        );
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
            .then(keywordData => {
                this.keyword = keywordData;

                $uibModal.open({
                    component: 'iconModal',
                    resolve: {
                        icon: () => clockIcon,
                        title: () => i18next.t('surveys:keyword.requested'),
                        paragraphs: () => [
                            i18next.t('surveys:keyword.requested_message'),
                        ],
                        closeLabel: () => i18next.t('ok'),
                    },
                });
            }, keywordErrorHandler);
    };

    this.deleteKeyword = keywordId => {
        if (!this.directAdminPrivileges) return;

        confirmModalService
            .create(tFilter('surveys:keyword:delete:confirm'))
            .then(() => {
                this.survey.keyword = {};
                this.keyword = {};
                surveyService.deleteKeyword(keywordId);
            });
    };

    this.saveKeyword = () => {
        if (!this.directAdminPrivileges) return;

        this.keywordError = '';
        if (!this.keyword.initial_response) {
            this.keywordError = tFilter(
                'surveys:keyword:errors:missingTextResponse',
            );
        }

        if (this.keywordError) {
            return;
        }

        surveyService
            .updateKeyword({
                keyword: this.keyword,
            })
            .then(angular.noop, keywordErrorHandler);
    };
}
