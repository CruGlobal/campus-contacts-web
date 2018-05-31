import template from './aboutModal.html';
import './aboutModal.scss';

angular
    .module('missionhubApp')
    .component('aboutModal', {
        controller: aboutModalController,
        template: template,
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

