(function () {
    angular
        .module('missionhubApp')
        .factory('personService', personService);

    function personService (httpProxy, apiEndPoint, _) {
        return {
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
