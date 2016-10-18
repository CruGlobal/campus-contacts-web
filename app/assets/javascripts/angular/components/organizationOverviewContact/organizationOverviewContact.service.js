(function () {

    'use strict';

    angular
        .module('missionhubApp')
        .factory('organizationOverviewContactService', organizationOverviewContactService);

    function organizationOverviewContactService (httpProxy, apiEndPoint, _) {
        function updatePerson (personId, payload) {
            return httpProxy.put(apiEndPoint.people.index + '/' + personId, null, payload);
        }

        return {
            // Persist attribute changes to a person (including changes to attributes of a person's relationship) on
            // the server
            saveAttribute: function (personId, model, attribute) {
                // Build up the changes object
                var changes = {
                    type: model._type,
                    id: model.id,
                    attributes: _.fromPairs([
                        [attribute, model[attribute]]
                    ])
                };

                // Update attributes on a person
                if (model._type === 'person') {
                    return updatePerson(personId, {
                        data: changes
                    });
                }

                // Updates attributes on a person's relation
                return updatePerson(personId, {
                    data: {
                        type: 'person'
                    },
                    included: [changes]
                });
            }
        };
    }

})();
