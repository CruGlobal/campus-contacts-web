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
        // Refresh the person list whenever the search term changes
        $scope.$watch('$select.search', search => {
            assignedPeopleSelectService
                .searchPeople(search, this.organizationId, requestDeduper)
                .then(people => {
                    if (this.assigned === null) {
                        this.people = people;
                    } else {
                        const assignedPeopleIds = this.assigned.map(
                            ({ id }) => id,
                        );
                        // Find all the current people in this.assigned
                        this.people = people.filter(
                            person => !assignedPeopleIds.includes(person.id),
                        );
                    }
                });
        });

        $scope.$watch('$ctrl.assigned', (o, n) => {
            if (this.actionAfterSelect && o !== n) {
                this.actionAfterSelect();
            }
        });
    };
}
