import template from './createSurvey.html';

angular.module('missionhubApp').component('createSurvey', {
    controller: createSurveyController,
    bindings: {
        resolve: '<',
        close: '&',
        dismiss: '&',
    },
    template: template,
});

function createSurveyController(surveyService) {
    var vm = this;

    vm.title = null;
    vm.saving = false;
    vm.survey = {};

    vm.valid = valid;
    vm.save = save;
    vm.cancel = cancel;

    vm.$onInit = activate;

    function activate() {
        vm.orgId = vm.resolve.organizationId;
    }

    function valid() {
        return vm.survey.title;
    }

    function save() {
        vm.saving = true;

        surveyService
            .createSurvey(vm.survey.title, vm.orgId)
            .then(function(newSurvey) {
                vm.close({ $value: newSurvey });
            })
            .catch(function() {
                vm.saving = false;
            });
    }

    function cancel() {
        vm.dismiss();
    }
}
