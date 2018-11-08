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

    vm.$onInit = activate;

    function activate() {
        $scope.$watchCollection(
            '$ctrl.person.organizational_permissions',
            function() {
                vm.orgPermission = personService.getOrgPermission(
                    vm.person,
                    vm.organizationId,
                );
            },
        );

        $scope.$watchCollection(
            '$ctrl.person.reverse_contact_assignments',
            function() {
                vm.assignedTo = personService.getAssignedTo(
                    vm.person,
                    vm.organizationId,
                );
            },
        );

        $scope.$watchCollection('$ctrl.person.answer_sheets', () => {
            if (!this.person.answer_sheets) vm.last_survey = null;

            vm.last_survey = this.person.answer_sheets.reduce((acc, s) => {
                const d1 = Date.parse(acc);
                const d2 = Date.parse(s.completed_at);

                if (!d1) return s.completed_at;

                return d1 < d2 ? s.completed_at : acc;
            }, '');
        });

        $scope.$watchCollection('$ctrl.person.phone_numbers', function() {
            vm.phoneNumber = personService.getPhoneNumber(vm.person);
        });

        $scope.$watchCollection('$ctrl.person.email_addresses', function() {
            vm.emailAddress = personService.getEmailAddress(vm.person);
        });
    }

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
