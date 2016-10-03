(function () {
    angular
        .module('missionhubApp')
        .factory('interactionsService', interactionsService);

    // This service contains action logic that is shared across components
    function interactionsService (httpProxy, apiEndPoint, JsonApiDataStore, loggedInPerson) {
        return {
            // Create a new interaction and save it on the server
            // interaction.id is the interaction_id, interaction.comment is the interaction comment,
            // organizationId is the organization_id of the associated organization, and personId is
            // the receiver of the interaction, or null if this is an anonymous interaction
            // Also, the initiator of the interaction is the currently logged-in user
            recordInteraction: function (interaction, organizationId, personId) {
                // Build up the relationships object
                var relationships = {
                    organization: {
                        data: {id: organizationId, type: 'organization'}
                    }
                };
                if (personId) {
                    relationships.receiver = {
                        data: {id: personId, type: 'person'}
                    };
                }
                var newInteraction = JsonApiDataStore.store.sync({
                    data: {
                        type: 'interaction',
                        attributes: {
                            comment: interaction.comment,
                            interaction_type_id: interaction.id
                        },
                        relationships: relationships
                    }
                });
                var createJson = newInteraction.serialize();
                createJson.included = [{
                    type: 'interaction_initiator',
                    attributes: {
                        person_id: loggedInPerson.person.id
                    }
                }];
                return httpProxy
                    .post(apiEndPoint.interactions.post, null, createJson);
            }
        };
    }
})();
