(function () {
    angular
        .module('missionhubApp')
        .factory('personService', personService);

    function personService (httpProxy, apiEndPoint, _) {
        return {
            // Return the follow-up status of the person in a particular organization
            getFollowupStatus: function (person, organizationId) {
                return _.chain(person.organizational_permissions)
                    .filter({ organization_id: organizationId })
                    .map('followup_status')
                    .first()
                    .defaultTo(null)
                    .value();
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
                    .put(apiEndPoint.people.update + person.id, null, updateJson)
                    .then(function () {
                        // Remove the archived person from the organization's list of people
                        _.remove(organizationalPermission.organization.people, { id: person.id });
                    });
            }
        }
    }
})();
