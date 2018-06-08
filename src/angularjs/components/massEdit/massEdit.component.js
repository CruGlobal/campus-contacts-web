import template from './massEdit.html';
import './massEdit.scss';

angular.module('missionhubApp').component('massEdit', {
  controller: massEditController,
  bindings: {
    resolve: '<',
    close: '&',
    dismiss: '&',
  },
  template: template,
});

function massEditController(massEditService, personService) {
  var vm = this;

  vm.saving = false;

  vm.save = save;
  vm.cancel = cancel;

  vm.changes = {};

  vm.selectFields = [
    {
      name: 'followup_status',
      options: personService.getFollowupStatusOptions(),
    },
    { name: 'cru_status', options: personService.getCruStatusOptions() },
    { name: 'student_status', options: personService.getEnrollmentOptions() },
    { name: 'gender', options: personService.getGenderOptions() },
  ];

  var unchangedOption = { id: null, i18n: 'mass_edit.unchanged' };
  vm.selectFields.forEach(function(selectField) {
    // Prepend the unchanged option to the list of options
    selectField.options.unshift(unchangedOption);

    vm.changes[selectField.name] = null;
  });

  vm.multiselectFields = massEditService.statDefinitions.map(function(
    statDefinition,
  ) {
    return {
      name: statDefinition.type,
      options: [],
      selection: {},
      ready: false,
    };
  });
  vm.multiselectFields.forEach(function(multiselectField) {
    vm.changes[multiselectField.name + '_added'] = [];
    vm.changes[multiselectField.name + '_removed'] = [];
  });

  vm.$onInit = activate;

  function activate() {
    var selection = vm.resolve.selection;

    // Load the relationships needed to determine which options are selected and the options themselves
    massEditService.loadOptions(selection).then(function(options) {
      vm.multiselectFields.forEach(function(multiselectField) {
        multiselectField.options = options[multiselectField.name];
        multiselectField.selection = massEditService.selectionFromOptions(
          multiselectField.options,
        );
        multiselectField.ready = true;
      });
    });
  }

  function save() {
    vm.saving = true;
    massEditService
      .applyChanges(vm.resolve.selection, vm.changes)
      .then(vm.close)
      .catch(function() {
        vm.saving = false;
      });
  }

  function cancel() {
    vm.dismiss();
  }
}
