(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('organizationOverviewLabels', {
            controller: organizationOverviewLabelsController,
            require: {
                organizationOverview: '^'
            },
            templateUrl: /* @ngInject */ function (templateUrl) {
                return templateUrl('organizationOverviewLabels');
            }
        });

    function organizationOverviewLabelsController ($uibModal, _) {
        var vm = this;
        vm.addLabel = addLabel;

        function addLabel () {
            $uibModal.open({
                component: 'editLabel',
                resolve: {
                    organizationId: _.constant(vm.organizationOverview.org.id)
                },
                windowClass: 'pivot_theme',
                size: 'sm'
            });
        }
    }
})();
