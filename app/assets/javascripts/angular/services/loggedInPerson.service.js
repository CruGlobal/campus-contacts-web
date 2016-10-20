(function () {
    angular
        .module('missionhubApp')
        .factory('loggedInPerson', loggedInPerson);

    function loggedInPerson (httpProxy, apiEndPoint, JsonApiDataStore, _) {
        var person = null;
        var loadingPromise = null;

        // Load the logged-in user's profile
        function loadMe () {
            return httpProxy.get(apiEndPoint.people.me, {
                include: 'user,organizational_permissions.organization'
            })
            .then(function (response) {
                // Lookup the user associated with the returned person
                var personId = response.data.id;
                return JsonApiDataStore.store.find('person', personId);
            });
        }

        // This service exposes an object with a person property that will be set to person model, or null if it has
        // not yet been loaded.
        return {
            // Return the person mode, or null if it has not yet been loaded
            get person () {
                return person;
            },

            set person (newPerson) {
                throw new Error('loggedInPerson.person is not settable!');
            },

            get loadingPromise () {
                return loadingPromise;
            },

            // Load (or reload) the person
            load: function () {
                loadingPromise = loadMe().then(function (me) {
                    person = me;
                    return me;
                });
                return loadingPromise;
            },

            // check if you have admin access on the org or any above it
            isAdminAt: function (org) {
                var adminOrgIds = _.chain(person.organizational_permissions)
                                   .filter({ permission_id: 1 })
                                   .map('organization_id')
                                   .value();
                var orgAndAncestry = org.ancestry.split('/');
                orgAndAncestry.push(org.id);
                return _.intersection(adminOrgIds, orgAndAncestry).length !== 0;
            }
        };
    }
})();
