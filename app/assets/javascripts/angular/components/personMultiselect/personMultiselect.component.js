import template from './personMultiselect.html';
import './personMultiselect.scss';

angular.module('missionhubApp').component('personMultiselect', {
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
    template: template,
});

function personMultiselectController(
    $scope,
    $q,
    RequestDeduper,
    assignedSelectService,
    tFilter,
    _,
) {
    var vm = this;

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

        var requestDeduper = new RequestDeduper();

        // Refresh the person list whenever the search term changes
        $scope.$watch('$ctrl.search', function(search) {
            if (search === '') {
                // Ignore empty searches
                vm.searchOptions = [];
                return;
            }

            vm.searching = true;
            assignedSelectService
                .searchPeople(search, vm.organizationId, requestDeduper)
                .then(function(people) {
                    // Filter out people that are already selected
                    vm.searchOptions = _.differenceBy(
                        people,
                        vm.selectedPeople,
                        'id',
                    );
                })
                .finally(function() {
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
        var addPerson = vm.addPerson || defaultAddPerson;
        $q.when(addPerson({ person: person })).then(function() {
            vm.search = '';
        });
    }

    function unselectPerson(person) {
        var removePerson = vm.removePerson || defaultRemovePerson;
        removePerson({ person: person });
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
