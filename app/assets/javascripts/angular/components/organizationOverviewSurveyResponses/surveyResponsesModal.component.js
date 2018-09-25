import modalTemplate from './surveyResponsesModal.html';

angular.module('missionhubApp').component('surveyResponseModal', {
    template: modalTemplate,
    bindings: {
        dismiss: '&',
    },
    controller: function($scope, localStorageService) {
        var vm = this;

        $scope.closeModal = function() {
            localStorageService.set('newSurveyResponseModal', true);
            vm.dismiss({ $value: 'cancel' });
        };
    },
});
