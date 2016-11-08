(function () {
    angular
        .module('missionhubApp')
        .factory('interactionsService', interactionsService);

    // This service contains action logic that is shared across components
    function interactionsService (httpProxy, modelsService, JsonApiDataStore, reportsService, loggedInPerson) {
        return {
            // Return an array containing information about the available interaction types
            // Fields:
            //   id: matches interaction_type_id
            //   icon: ng-md-icon icon name
            //   title: i18n key
            //   anonmyous: whether or not this interaction may be anonymous
            getInteractionTypes: function () {
                return [
                    {
                        id: 1,
                        icon: 'note',
                        title: 'application.interaction_types.comment',
                        anonymous: false
                    }, {
                        id: 2,
                        icon: 'spiritualConversation',
                        title: 'application.interaction_types.spiritual_conversation',
                        anonymous: true
                    }, {
                        id: 3,
                        icon: 'evangelism',
                        title: 'application.interaction_types.gospel_presentation',
                        anonymous: true
                    }, {
                        id: 4,
                        icon: 'personalDecision',
                        title: 'application.interaction_types.prayed_to_receive_christ',
                        anonymous: true
                    }, {
                        id: 5,
                        icon: 'holySpirit',
                        title: 'application.interaction_types.holy_spirit_presentation',
                        anonymous: true
                    }, {
                        id: 9,
                        icon: 'discipleship',
                        title: 'application.interaction_types.discipleship',
                        anonymous: false
                    }
                ];
            },

            // Create a new interaction and save it on the server
            // interaction.interactionTypeId is the interaction_type_id, interaction.comment is the interaction
            // comment, organizationId is the organization_id of the associated organization, and personId is
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
                            interaction_type_id: interaction.interactionTypeId
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
                return httpProxy.post(modelsService.getModelMetadata('interactions').url.root, null, createJson)
                    .then(httpProxy.extractModel)
                    .then(function (interaction) {
                        interaction.initiators.forEach(function (initiator) {
                            // Add the new interaction to the person report
                            var report = reportsService.lookupPersonReport(interaction.organization.id, initiator.id);
                            reportsService.incrementReportInteraction(report, interaction.interaction_type_id);
                        });

                        // Add the new interaction to the organization report
                        var report = reportsService.lookupOrganizationReport(interaction.organization.id);
                        reportsService.incrementReportInteraction(report, interaction.interaction_type_id);
                    });
            }
        };
    }
})();
