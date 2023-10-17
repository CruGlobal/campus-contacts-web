import template from './personMultiselect.html';
import './personMultiselect.scss';

angular.module('campusContactsApp').component('personMultiselect', {
  controller: personMultiselectController,
  bindings: {
    organizationId: '<',

    // An array of the selected people
    // This component does not manipulate that array; it relies on addPerson and removePerson to do that
    selectedPeople: '<',

    // When passed a person, adds the person to the selected people list and return a promise that resolves
    // when the add operation completes
    addPerson: '&?',

    // When passed a person, removes the person from the selected people list and return a promise that
    // resolves when the remove operation completes
    removePerson: '&?',

    // The label of the phrase used to describe people (i.e. contact, person, leader, member, etc.) that
    // will be interpolated into messages
    peopleDescriptionLabel: '=peopleDescription',

    focused: '=?',
  },
  template,
});

function personMultiselectController($scope, $q, RequestDeduper, assignedPeopleSelectService, tFilter, _) {
  const vm = this;

  vm.search = '';
  vm.selectPerson = selectPerson;
  vm.unselectPerson = unselectPerson;
  vm.onSearchKeydown = onSearchKeydown;

  vm.$onInit = activate;

  function activate() {
    _.defaults(vm, {
      focused: true,
    });

    vm.peopleDescription = tFilter(vm.peopleDescriptionLabel);

    const requestDeduper = new RequestDeduper();

    // Refresh the person list whenever the search term changes
    $scope.$watch('$ctrl.search', function (search) {
      if (search === '') {
        // Ignore empty searches
        vm.searchOptions = [];
        return;
      }

      vm.searching = true;
      assignedPeopleSelectService
        .searchPeople(search, vm.organizationId, requestDeduper)
        .then(function (people) {
          // Filter out people that are already selected
          vm.searchOptions = _.differenceBy(people, vm.selectedPeople, 'id');
        })
        .finally(function () {
          vm.searching = false;
        });
    });
  }

  // The default add-person binding appends the person to the selected people array
  function defaultAddPerson(context) {
    vm.selectedPeople.push(context.person);
  }

  // The default add-person binding removes the person from the selected people array
  function defaultRemovePerson(context) {
    _.pull(vm.selectedPeople, context.person);
  }

  function selectPerson(person) {
    const addPerson = vm.addPerson || defaultAddPerson;
    $q.when(addPerson({ person })).then(function () {
      vm.search = '';
    });
  }

  function unselectPerson(person) {
    const removePerson = vm.removePerson || defaultRemovePerson;
    removePerson({ person });
  }

  function onSearchKeydown(event) {
    if (event.keyCode === 13) {
      // Enter key was pressed, so add the person option if it is the only one
      if (vm.searchOptions.length === 1) {
        selectPerson(vm.searchOptions[0]);
      }
    }
  }
}
