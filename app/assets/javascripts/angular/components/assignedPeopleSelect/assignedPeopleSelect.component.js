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
    this.originalPeople = [];
    this.isMe = assignedPeopleSelectService.isMe;
    this.$onInit = () => {
        const requestDeduper = new RequestDeduper();
        // Keep an original copy of all the people so we do not have to continually query
        assignedPeopleSelectService
            .searchPeople(this.organizationId, requestDeduper)
            .then(people => {
                this.originalPeople = people;
            });
        // Refresh the person list whenever the search term changes
        $scope.$watch('$select.search', search => {
            if (search === '') {
                // Ignore empty searches
                this.people = [...this.originalPeople];
                return;
            }
            // Just filter through our originalPeople array to find people who match the users search
            this.people = this.originalPeople.filter(
                person =>
                    person.first_name
                        .toLowerCase()
                        .includes(search.toLowerCase()) ||
                    person.last_name
                        .toLowerCase()
                        .includes(search.toLowerCase()),
            );
        });

        $scope.$watch('$ctrl.assigned', (o, n) => {
            if (this.actionAfterSelect && o !== n) {
                this.actionAfterSelect();
            }
        });
    };
}
