(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('aboutModal', {
            controller: aboutModalController,
            templateUrl: /* @ngInject */ function (templateUrl) {
                return templateUrl('aboutModal');
            },
            bindings: {
                resolve: '<',
                close: '&',
                dismiss: '&'
            }
        })
        .run(/* @ngInject */ function ($rootScope, $uibModal) {
            $rootScope.openAboutModal = function () {
                $uibModal.open({
                    component: 'aboutModal',
                    windowClass: 'pivot_theme',
                    size: 'md'
                });
            };
        });

    function aboutModalController () {
        var vm = this;

        vm.year = new Date().getFullYear();

        vm.$onInit = activate;

        function activate () {

        }
    }
})();
