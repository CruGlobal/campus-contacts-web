(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('mergeWinnerModal', {
            controller: mergeWinnerModalController,
            templateUrl: /* @ngInject */ function (templateUrl) {
                return templateUrl('mergeWinnerModal');
            },
            bindings: {
                resolve: '<',
                close: '&',
                dismiss: '&'
            }
        });

    function mergeWinnerModalController (mergeWinnerService) {
        var vm = this;

        vm.personFields = mergeWinnerService.personFields;
        vm.userFields = mergeWinnerService.userFields;

        vm.choices = null;
        vm.winner = null;
        vm.ready = false;
        vm.setWinner = setWinner;
        vm.save = save;
        vm.cancel = cancel;

        vm.$onInit = activate;

        function activate () {
            mergeWinnerService.generateChoices(vm.resolve.choices)
                .then(function (choices) {
                    vm.ready = true;
                    vm.choices = choices;
                })
                .catch(function (err) {
                    vm.dismiss({ $value: err });
                });
        }

        function setWinner (model) {
            vm.winner = model;
        }

        function save () {
            vm.close({ $value: vm.winner });
        }

        function cancel () {
            vm.dismiss();
        }
    }
})();
