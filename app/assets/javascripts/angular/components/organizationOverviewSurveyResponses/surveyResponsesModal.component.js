import modalTemplate from './surveyResponsesModal.html';

angular.module('missionhubApp').component('surveyResponseModal', {
    template: modalTemplate,
    bindings: {
        dismiss: '&',
    },
    controller: function() {
        this.closeModal = () => {
            this.dismiss({ $value: 'cancel' });
        };
    },
});
