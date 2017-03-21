(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('personService', personService);

    function personService (httpProxy, modelsService, JsonApiDataStore, _) {
        // Convert an array of string ids into an array of options with the schema { id, i18n }
        // Used by personService.get*Options()
        function generateOptionsFromIds (ids, i18nPrefix) {
            return ids.map(function (id) {
                return {
                    id: id,
                    i18n: i18nPrefix + '.' + id
                };
            });
        }

        var personService = {
            // Find and return a person's organizational permission for a particular organization
            getOrgPermission: function (person, organizationId) {
                return _.chain(person.organizational_permissions)
                    .filter({ organization_id: organizationId })
                    .first()
                    .defaultTo(null)
                    .value();
            },

            getOrgLabels: function (person, organizationId) {
                return _.filter(person.organizational_labels, { organization_id: organizationId });
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

            // Given a person in a particular organization, return the people that that person is assigned to
            getAssignedTo: function (person, organizationId) {
                return _.chain(person.reverse_contact_assignments)
                    .filter(['organization.id', organizationId])
                    .map('assigned_to')
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

            // Return the person's group memberships
            getGroupMemberships: function (person, organizationId) {
                return _.filter(person.group_memberships, ['group.organization.id', organizationId]);
            },

            // These methods return array of all possible options for a particular person attribute
            // Each option has an "id" property that is the database value and an "i18n" value that is the label path

            // Return an array of followup status options
            getFollowupStatusOptions: function () {
                return generateOptionsFromIds([
                    'attempted_contact',
                    'completed',
                    'contacted',
                    'do_not_contact',
                    'uncontacted'
                ], 'followup_status');
            },

            // Return an array of Cru status options
            getCruStatusOptions: function () {
                return generateOptionsFromIds([
                    'none',
                    'volunteer',
                    'affiliate',
                    'intern',
                    'part_time_staff',
                    'full_time_staff'
                ], 'cru_status');
            },

            // Return an array of permission options
            getPermissionOptions: function () {
                return [
                    { id: 1, i18n: 'permissions.admin' },
                    { id: 4, i18n: 'permissions.user' },
                    { id: 2, i18n: 'permissions.no_permissions' }
                ];
            },

            // Return an array of enrollment options
            getEnrollmentOptions: function () {
                return generateOptionsFromIds([
                    'not_student',
                    'middle_school',
                    'high_school',
                    'collegiate',
                    'masters_or_doctorate'
                ], 'student_status');
            },

            // Return an array of gender options
            getGenderOptions: function () {
                return [
                    { id: 'Male', i18n: 'general.male' },
                    { id: 'Female', i18n: 'general.female' }
                ];
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
                        return _.isNil(organizationId) || _.get(assignment, 'organization.id') === organizationId;
                    }

                    // Check whether the assigned person is in the organization that the assignment is in
                    function isAssignedPersonInAssignmentOrganization (assignment, assignedPerson) {
                        if (!assignment.organization) {
                            // we currently don't support non-organization people
                            return false;
                        }
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
