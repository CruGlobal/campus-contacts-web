import template from './editLabel.html';

angular.module('campusContactsApp').component('editLabel', {
  controller: editLabelController,
  bindings: {
    resolve: '<',
    close: '&',
    dismiss: '&',
  },
  template,
});

function editLabelController(labelsService, _) {
  const vm = this;

  vm.title = null;
  vm.saving = false;

  vm.valid = valid;
  vm.save = save;

  vm.$onInit = activate;

  function activate() {
    vm.orgId = vm.resolve.organizationId;
    const labelTemplate = labelsService.getLabelTemplate(vm.orgId);
    vm.label = _.clone(vm.resolve.label || labelTemplate);

    vm.title = vm.label.id ? 'labels.edit.edit_label' : 'labels.new.new_label';
  }

  function valid() {
    return Boolean(vm.label.name);
  }

  function save() {
    vm.saving = true;

    return labelsService
      .saveLabel(vm.label)
      .then(function (newLabel) {
        vm.close({ $value: newLabel });
      })
      .catch(function () {
        vm.saving = false;
      });
  }
}
