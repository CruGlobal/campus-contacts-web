(function () {
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
                return _.chain(person.phone_numbers).find({ primary: true }).defaultTo(null).value();
            },

            // Return the person's primary email address
            getEmailAddress: function (person) {
                return _.chain(person.email_addresses).find({ primary: true }).defaultTo(null).value();
            },

            archivePerson: function (person, organizationId) {
                var organizationalPermission = _.find(person.organizational_permissions, {
                    organization_id: organizationId
                });
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
                    .put(modelsService.getModelMetadata('person').url.single(person.id), null, updateJson)
                    .then(function () {
                        // Remove the archived person from the organization's list of people
                        _.remove(organizationalPermission.organization.people, { id: person.id });
                    });
            },

            // Return a promise that resolve to an array of the contact assignments for people assigned to a
            // particular person
            // If organization is null, return all contact assignments, otherwise filter the returned assignments to
            // those related to a particular organization
            getContactAssignments: function (person, organization) {
                return httpProxy.get(modelsService.getModelMetadata('person').url.all, {
                    include: [
                        // When we have an organization, we do not need to load the contact assignments' organizations
                        _.isNil(organization) ?
                            'reverse_contact_assignments.organization' :
                            'reverse_contact_assignments',
                        'organizational_permissions'
                    ].join(','),
                    'filters[assigned_tos]': person.id,
                    'filters[organizations_id]': _.isNil(organization) ? '' : organization.id,
                    'page[limit]': 1000
                }).then(httpProxy.extractModels).then(function (assignedPeople) {
                    // Determine whether the assignment
                    function isRelevantAssignment (assignment, assignedPerson) {
                        // Make sure that the person is assigned to the person in question
                        return assignment.assigned_to.id === person.id &&
                            // Make sure that the assignment is related to an organization that the person is a part of
                            _.find(assignedPerson.organizational_permissions, {
                                organization_id: assignment.organization.id
                            }) &&
                            // Make sure that the assignment is related to the specified organization
                            (_.isNil(organization) || assignment.organization.id === organization.id);
                    }

                    // Start with the array of assigned people, map it to an array of contact assignment arrays,
                    // then flatten it into a one-dimensional array
                    return _.flatten(assignedPeople.map(function (assignedPerson) {
                        // Include only the relevant contact assigments
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
