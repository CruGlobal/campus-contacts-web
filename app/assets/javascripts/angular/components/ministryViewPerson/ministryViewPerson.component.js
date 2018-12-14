import template from './ministryViewPerson.html';
import './ministryViewPerson.scss';

angular.module('missionhubApp').component('ministryViewPerson', {
    controller: ministryViewPersonController,
    template: template,
    bindings: {
        person: '<',
        organizationId: '<',
        selected: '=',
        questions: '<',
        odd: '<',
        showLastSurvey: '=',
    },
});

function ministryViewPersonController(
    $scope,
    personService,
    personProfileService,
) {
    var vm = this;

    vm.loadingAssignmentOptions = false;
    vm.addAssignment = addAssignment;
    vm.removeAssignment = removeAssignment;
    vm.saveAttribute = saveAttribute;
    vm.toggleAssignmentVisibility = toggleAssignmentVisibility;
    vm.onAssignmentsKeydown = onAssignmentsKeydown;
    vm.isContact = isContact;
    vm.followupStatusOptions = personService.getFollowupStatusOptions();

    this.$onChanges = changes => {
        if (changes.person.currentValue === changes.person.previousValue)
            return;

        const person = changes.person.currentValue;

        if (this.showLastSurvey) {
            if (!person.answer_sheets) this.lastSurvey = null;

            this.lastSurvey = personService.getLastSurvey(person);
        }

        this.orgPermission = personService.getOrgPermission(
            person,
            this.organizationId,
        );

        this.assignedTo = personService.getAssignedTo(
            person,
            this.organizationId,
        );

        this.phoneNumber = personService.getPhoneNumber(person);
        this.emailAddress = personService.getEmailAddress(person);
    };

    function addAssignment(person) {
        return personProfileService
            .addAssignments(vm.person, vm.organizationId, [person])
            .then(() => $scope.$emit('personModified'));
    }

    function removeAssignment(person) {
        return personProfileService
            .removeAssignments(vm.person, [person])
            .then(() => $scope.$emit('personModified'));
    }

    function saveAttribute(model, attribute) {
        personProfileService
            .saveAttribute(vm.person.id, model, attribute)
            .then(() => $scope.$emit('personModified'));
    }

    function toggleAssignmentVisibility() {
        vm.assignmentsVisible = !vm.assignmentsVisible;
    }

    function onAssignmentsKeydown(event) {
        if (event.keyCode === 27) {
            // Escape key was pressed, so hide the assignments selector
            vm.assignmentsVisible = false;
        }
    }

    function isContact() {
        return personService.isContact(vm.person, vm.organizationId);
    }
}
