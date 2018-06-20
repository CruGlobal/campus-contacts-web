import template from './ministryViewLabel.html';
import './ministryViewLabel.scss';

angular.module('missionhubApp').component('ministryViewLabel', {
    controller: ministryViewLabelController,
    template: template,
    bindings: {
        label: '<',
    },
});

function ministryViewLabelController(
    $uibModal,
    confirmModalService,
    tFilter,
    labelsService,
    loggedInPerson,
    _,
) {
    var vm = this;

    vm.editLabel = editLabel;
    vm.deleteLabel = deleteLabel;
    vm.$onInit = activate;

    function activate() {
        vm.adminPrivileges = loggedInPerson.isAdminAt(vm.label.organization);
    }

    function editLabel() {
        $uibModal.open({
            component: 'editLabel',
            resolve: {
                organizationId: _.constant(vm.label.organization.id),
                label: _.constant(vm.label),
            },
            windowClass: 'pivot_theme',
            size: 'sm',
        });
    }

    function deleteLabel() {
        return confirmModalService
            .create(
                tFilter('labels.delete.confirm', { label_name: vm.label.name }),
            )
            .then(function() {
                return labelsService.deleteLabel(vm.label);
            });
    }
}
