(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('personService', personService);

    function personService (httpProxy, modelsService, JsonApiDataStore, _) {
        var personService = {
            // Find and return a person's organizational permission for a particular organization
            getOrgPermission: function (person, organizationId) {
                return _.chain(person.organizational_permissions)
                    .filter({ organization_id: organizationId })
                    .first()
                    .defaultTo(null)
                    .value();
            },

            // Return the follow-up status of the person in a particular organization
            getFollowupStatus: function (person, organizationId) {
                var orgPermission = personService.getOrgPermission(person, organizationId);
                return orgPermission && orgPermission.followup_status;
            },

            // Return the Cru status of the person in a particular organization
            getCruStatus: function (person, organizationId) {
                var orgPermission = personService.getOrgPermission(person, organizationId);
                return orgPermission && orgPermission.cru_status;
            },

            // Given a person in a particular organization, return the person that that person is assigned to
            getAssignedTo: function (person, organizationId) {
                return _.chain(person.reverse_contact_assignments)
                    .filter(['organization.id', organizationId])
                    .map('assigned_to')
                    .first()
                    .defaultTo(null)
                    .value();
            },

            // Return the person's primary phone number
            getPhoneNumber: function (person) {
                return _.chain(person.phone_numbers)
                    .find({ primary: true })
                    .defaultTo(null)
                    .value();
            },

            // Return the person's primary email address
            getEmailAddress: function (person) {
                return _.chain(person.email_addresses)
                    .find({ primary: true })
                    .defaultTo(null)
                    .value();
            },

            // Archive the person in a particular organization
            archivePerson: function (person, organizationId) {
                var organizationalPermission = personService.getOrgPermission(person, organizationId);
                var updateJson = {
                    data: {
                        type: 'person',
                        attributes: {}
                    },
                    included: [
                        {
                            type: 'organizational_permission',
                            id: organizationalPermission.id,
                            attributes: {
                                archive_date: (new Date()).toUTCString()
                            }
                        }
                    ]
                };
                return httpProxy
                    .put(modelsService.getModelUrl(person), updateJson)
                    .then(function () {
                        // Remove the archived person from the organization's list of people
                        _.remove(organizationalPermission.organization.people, { id: person.id });
                    });
            },

            // Return a promise that resolves to an array of the contact assignments for people assigned to a
            // particular person
            // If organization is null, return all contact assignments, otherwise filter the returned assignments to
            // those related to a particular organization
            getContactAssignments: function (person, organizationId) {
                return httpProxy.get(modelsService.getModelMetadata('person').url.all, {
                    include: [
                        // When we have an organization, we do not need to load the contact assignments' organizations
                        _.isNil(organizationId) ?
                            'reverse_contact_assignments.organization' :
                            'reverse_contact_assignments',
                        'organizational_permissions'
                    ].join(','),
                    'filters[assigned_tos]': person.id,
                    'filters[organizations_id]': _.isNil(organizationId) ? '' : organizationId,
                    'page[limit]': 1000
                })
                .then(httpProxy.extractModels)
                .then(function (assignedPeople) {
                    // Check whether the person is assigned to the person that we are getting assignments for
                    function isAssignmentForCurrentPerson (assignment) {
                        return assignment.assigned_to.id === person.id;
                    }

                    // Check whether the assignment is in the organization that we are getting assignments for
                    function isAssignmentInCurrentOrganization (assignment) {
                        return _.isNil(organizationId) || assignment.organization.id === organizationId;
                    }

                    // Check whether the assigned person is in the organization that the assignment is in
                    function isAssignedPersonInAssignmentOrganization (assignment, assignedPerson) {
                        return _.find(assignedPerson.organizational_permissions, {
                            organization_id: assignment.organization.id
                        });
                    }

                    // Determine whether the assignment should be included in the returned list
                    function isRelevantAssignment (assignment, assignedPerson) {
                        return isAssignmentForCurrentPerson(assignment) &&
                            isAssignmentInCurrentOrganization(assignment) &&
                            isAssignedPersonInAssignmentOrganization(assignment, assignedPerson);
                    }

                    // Start with the array of assigned people, map it to an array of contact assignment arrays,
                    // then flatten it into a one-dimensional array
                    return _.flatten(assignedPeople.map(function (assignedPerson) {
                        // Include only the relevant contact assignments
                        return assignedPerson.reverse_contact_assignments.filter(function (assignment) {
                            return isRelevantAssignment(assignment, assignedPerson);
                        });
                    }));
                });
            }
        };

        return personService;
    }
})();
