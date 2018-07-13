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
    asyncBindingsService,
    surveyService,
) {
    var vm = this;
    vm.helpIcon = helpIcon;

    vm.$onInit = asyncBindingsService.lazyLoadedActivate(() => {
        vm.keyword = angular.copy(vm.survey.keyword) || {};

        vm.disableKeywordField =
            vm.keyword.keyword &&
            _.includes(['requested', 'active'], vm.keyword.state);
    }, []);

    vm.requestKeyword = () => {
        vm.keywordError = false;

        surveyService
            .requestKeyword({
                surveyId: vm.survey.id,
                orgId: vm.survey.organization_id,
                keyword: vm.keyword,
            })
            .then(
                keywordData => {
                    vm.keyword = keywordData;

                    $uibModal.open({
                        component: 'keywordRequestModal',
                        windowClass: 'pivot_theme',
                        size: 'md',
                    });
                },
                () => {
                    vm.keywordError = true;
                },
            );
    };

    vm.deleteKeyword = keywordId => {
        vm.survey.keyword = {};
        vm.keyword = {};
        surveyService.deleteKeyword(keywordId);
    };
}
