(function () {
    angular
        .module('missionhubApp')
        .factory('loggedInPerson', loggedInPerson);

    function loggedInPerson (httpProxy, apiEndPoint, JsonApiDataStore) {
        var person = null;

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

            // Load (or reload) the person
            load: function () {
                return loadMe().then(function (me) {
                    person = me;
                    return me;
                });
            }
        };
    }
})();
