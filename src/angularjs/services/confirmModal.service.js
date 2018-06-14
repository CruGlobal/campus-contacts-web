confirmModalService.$inject = ['$uibModal'];
/* eslint max-len: ["error", { "ignoreStrings": true }] */

angular
  .module('missionhubApp')
  .factory('confirmModalService', confirmModalService);

function confirmModalService($uibModal) {
  return {
    create: function(message) {
      var modalInstance = $uibModal.open({
        animation: true,
        controller: [
          '$uibModalInstance',
          function($uibModalInstance) {
            var vm = this;
            vm.cancel = function() {
              $uibModalInstance.dismiss('cancel');
            };
            vm.confirm = function() {
              $uibModalInstance.close('delete');
            };
          },
        ],
        controllerAs: 'vm',
        windowClass: 'pivot_theme',
        size: 'sm',
        template: [
          '<div>',
          '<div class="modal-header">',
          '<h3 class="confirm-title" id="modal-title">Confirm</h3>',
          '</div>',
          '<div class="modal-body">' + message + '</div>',
          '<div class="modal-footer">',
          '<button class="btn btn-secondary" type="button" ng-click="vm.cancel()">{{"general.cancel" | t}}</button>',
          '<button class="btn btn-primary" type="button" ng-click="vm.confirm()">{{"general.ok" | t}}</button>',
          '</div>',
          '</div>',
        ].join(''),
      });

      return modalInstance.result;
    },
  };
}
