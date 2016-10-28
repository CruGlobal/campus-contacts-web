(function () {
    angular
        .module('missionhubApp')
        .factory('routesService', routesService);

    // This service contains logic used by the routes
    function routesService (httpProxy, apiEndPoint) {
        return {
            // Return a promise that resolves to the specified person in the specified organization, loading that
            // person if necessary
            getPerson: function (personId) {
                var url = apiEndPoint.people.index + '/' + personId;
                return httpProxy.getModel(url, 'person', personId, [
                    'phone_numbers',
                    'email_addresses',
                    'organizational_permissions',
                    'reverse_contact_assignments.assigned_to'
                ]);
            },

            // Return a promise that resolves to the specified organization, loading that organization if necessary
            getOrganization: function (organizationId) {
                var url = apiEndPoint.organizations.index + '/' + organizationId;
                return httpProxy.getModel(url, 'organization', organizationId, []);
            },

            // Load a person's interaction history (which consists of interactions as well as survey responses)
            getHistory: function (personId) {
                var url = apiEndPoint.people.index + '/' + personId;
                return httpProxy.getModel(url, 'person', personId, [
                    'interactions',
                    'answer_sheets.answers.question'
                ]);
            }
        };
    }
})();
