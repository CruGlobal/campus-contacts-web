import modalTemplate from './surveyResponsesModal.html';

angular.module('missionhubApp').component('surveyResponseModal', {
    template: modalTemplate,
    bindings: {
        dismiss: '&',
    },
    controller: function($scope, localStorageService) {
        var vm = this;

        $scope.closeModal = function() {
            vm.dismiss({ $value: 'cancel' });
        };
    },
});
