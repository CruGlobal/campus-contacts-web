/* eslint max-len: ["error", { "ignoreStrings": true }] */

angular
    .module('missionhubApp')
    .factory('confirmModalService', confirmModalService);

function confirmModalService($uibModal) {
    return {
        create: function(message, options) {
            // eslint-disable-next-line no-param-reassign
            options = {
                showCancel: true,
                title: 'Confirm',
                ...options,
            };
            var modalInstance = $uibModal.open({
                animation: true,
                controller: function($uibModalInstance) {
                    var vm = this;
                    vm.cancel = function() {
                        $uibModalInstance.dismiss('cancel');
                    };
                    vm.confirm = function() {
                        $uibModalInstance.close('delete');
                    };
                },
                controllerAs: 'vm',
                windowClass: 'pivot_theme',
                size: 'sm',
                template: [
                    '<div>',
                    '<div class="modal-header">',
                    '<h3 class="modal-title" id="modal-title">' +
                        options.title +
                        '</h3>',
                    '<a ng-click="vm.cancel()" class="close-button">',
                    '<ng-md-icon icon="close" size="28"></ng-md-icon>',
                    '</a>',
                    '</div>',
                    '<div class="modal-body">' + message + '</div>',
                    '<div class="modal-footer">',
                    options.showCancel
                        ? '<button class="btn btn-secondary" type="button" ng-click="vm.cancel()">{{"general.cancel" | t}}</button>'
                        : '',
                    '<button class="btn btn-primary" type="button" ng-click="vm.confirm()">{{"general.ok" | t}}</button>',
                    '</div>',
                    '</div>',
                ].join(''),
            });

            return modalInstance.result;
        },
    };
}
