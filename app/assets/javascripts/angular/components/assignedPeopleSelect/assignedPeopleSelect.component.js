import template from './assignedPeopleSelect.html';
import './assignedPeopleSelect.scss';

angular.module('missionhubApp').component('assignedPeopleSelect', {
    bindings: {
        assigned: '=',
        ruleCode: '<',
        organizationId: '<',
        disabled: '<',
        actionAfterSelect: '&',
    },
    controller: assignedPeopleSelectController,
    template: template,
});

function assignedPeopleSelectController(
    $scope,
    assignedPeopleSelectService,
    RequestDeduper,
) {
    this.people = [];
    this.isMe = assignedPeopleSelectService.isMe;
    this.$onInit = () => {
        const requestDeduper = new RequestDeduper();
        // Keep an original copy of all the people so we do not have to continually query

        // Refresh the person list whenever the search term changes
        $scope.$watch('$select.search', search => {
            if (search === '') {
                // Ignore empty searches
                this.people = [];
                return;
            }

            assignedPeopleSelectService
                .searchPeople(search, this.organizationId, requestDeduper)
                .then(people => {
                    // Find all the current people in this.assigned
                    const currentPeople = people.filter(person => {
                        return this.assigned.some(assignedPerson => {
                            return assignedPerson.id === person.id;
                        });
                    });
                    // Map through all the people and if the currentPeople array does not include the person return that person
                    // However it will produce undefined for a person if they are in current people so we then filter out all values that are undefined
                    this.people = people
                        .map(person => {
                            if (currentPeople.includes(person)) {
                                return;
                            }
                            return person;
                        })
                        .filter(person => person !== undefined);
                });
        });

        $scope.$watch('$ctrl.assigned', (o, n) => {
            if (this.actionAfterSelect && o !== n) {
                this.actionAfterSelect();
            }
        });
    };
}
