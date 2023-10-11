import template from './editGroupOrLabelAssignments.html';
import './editGroupOrLabelAssignments.scss';

angular.module('campusContactsApp').component('editGroupOrLabelAssignments', {
  controller: editGroupOrLabelAssignmentsController,
  bindings: {
    resolve: '<',
    close: '&',
    dismiss: '&',
  },
  template,
});

function editGroupOrLabelAssignmentsController(editGroupOrLabelAssignmentsService, JsonApiDataStore, _) {
  const vm = this;

  vm.saving = false;
  vm.entryOptions = [];
  vm.selectedEntries = {};
  vm.addedEntries = [];
  vm.removedEntries = [];

  vm.save = save;
  vm.cancel = cancel;

  vm.$onInit = activate;

  function activate() {
    loadEntryOptions();
    buildSelectedDict();

    const title = isOrgLabelsMode() ? 'people.show.apply_labels' : 'people.show.apply_groups';
    vm.title = vm.resolve.person.first_name ? title : `${title}_undefined`;
    vm.subtitle = isOrgLabelsMode() ? 'people.index.labels' : 'nav.groups';
  }

  function isOrgLabelsMode() {
    return vm.resolve.relationship === 'organizational_labels';
  }

  function orgRelationship() {
    return isOrgLabelsMode() ? 'labels' : 'groups';
  }

  function relatedModel() {
    return isOrgLabelsMode() ? 'label' : 'group';
  }

  function sortFunction() {
    if (isOrgLabelsMode()) {
      return function (organization) {
        return parseInt(organization.id, 10);
      };
    }
    return 'name';
  }

  function orgFilterExpression() {
    if (isOrgLabelsMode()) {
      return { organization_id: vm.resolve.organizationId };
    }
    return ['group.organization.id', vm.resolve.organizationId];
  }

  function errorMessage() {
    return isOrgLabelsMode()
      ? 'error.messages.edit_group_or_label_assignments.load_labels'
      : 'error.messages.edit_group_or_label_assignments.load_groups';
  }

  function loadEntryOptions() {
    const entries = JsonApiDataStore.store.find('organization', vm.resolve.organizationId)[orgRelationship()];
    vm.entryOptions = _.sortBy(entries, sortFunction());
    editGroupOrLabelAssignmentsService.loadPlaceholderEntries(entries, vm.resolve.organizationId, errorMessage());
  }

  function buildSelectedDict() {
    vm.selectedEntries = _.chain(vm.resolve.person[vm.resolve.relationship])
      .filter(orgFilterExpression())
      .map(function (entry) {
        return [entry[relatedModel()].id, true];
      })
      .fromPairs()
      .value();
  }

  function save() {
    let savingPromise;
    vm.saving = true;
    if (isOrgLabelsMode()) {
      savingPromise = editGroupOrLabelAssignmentsService.saveOrganizationalLabels(
        vm.resolve.person,
        vm.resolve.organizationId,
        vm.addedEntries,
        vm.removedEntries,
      );
    } else {
      savingPromise = editGroupOrLabelAssignmentsService.saveGroupMemberships(
        vm.resolve.person,
        vm.addedEntries,
        vm.removedEntries,
      );
    }

    savingPromise.then(vm.close).catch(function () {
      vm.saving = false;
    });
  }

  function cancel() {
    vm.dismiss();
  }
}
