angular.module('campusContactsApp').factory('personAssignedService', personAssignedService);

function personAssignedService(JsonApiDataStore, personService) {
  return {
    // Return an array of information items about the people assigned to a particular person in a
    // particular organization
    getAssigned: function (person, organizationId) {
      // Return information about a contact assignment (currently the assignee and followup status)
      function assignmentInfoFromAssignment(assignment) {
        const person = JsonApiDataStore.store.find('person', assignment.person_id);
        const orgId = assignment.organization.id;
        return {
          person,
          followup_status: personService.getFollowupStatus(person, orgId) || 'uncontacted',
        };
      }

      return personService.getContactAssignments(person, organizationId).then(function (assignments) {
        return assignments.map(assignmentInfoFromAssignment);
      });
    },
  };
}
