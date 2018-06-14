interactionsService.$inject = [
  'httpProxy',
  'modelsService',
  'JsonApiDataStore',
  'reportsService',
  'loggedInPerson',
  '_',
];
angular
  .module('missionhubApp')
  .factory('interactionsService', interactionsService);

// This service contains action logic that is shared across components
function interactionsService(
  httpProxy,
  modelsService,
  JsonApiDataStore,
  reportsService,
  loggedInPerson,
  _,
) {
  // Fields:
  //   id: matches interaction_type_id
  //   icon: ng-md-icon icon name
  //   title: i18n key
  //   anonmyous: whether or not this interaction may be anonymous
  //   deprecated: whether or not this interaction type is deprecated
  var interactionTypes = [
    {
      id: 1,
      icon: 'note',
      title: 'application.interaction_types.comment',
      anonymous: false,
      deprecated: false,
    },
    {
      id: 2,
      icon: 'spiritualConversation',
      title: 'application.interaction_types.spiritual_conversation',
      anonymous: true,
      deprecated: false,
    },
    {
      id: 3,
      icon: 'evangelism',
      title: 'application.interaction_types.gospel_presentation',
      anonymous: true,
      deprecated: false,
    },
    {
      id: 4,
      icon: 'personalDecision',
      title: 'application.interaction_types.prayed_to_receive_christ',
      anonymous: true,
      deprecated: false,
    },
    {
      id: 5,
      icon: 'holySpirit',
      title: 'application.interaction_types.holy_spirit_presentation',
      anonymous: true,
      deprecated: false,
    },
    {
      id: 6,
      icon: 'graduatingOnMission',
      title: 'application.interaction_types.graduating_on_mission',
      anonymous: true,
      deprecated: true,
    },
    {
      id: 9,
      icon: 'discipleship',
      title: 'application.interaction_types.discipleship',
      anonymous: false,
      deprecated: false,
    },
  ];

  return {
    // Return an array containing information about the available interaction types
    getInteractionTypes: function() {
      // Excluded deprecated interaction types
      return _.filter(interactionTypes, { deprecated: false });
    },

    // Lookup and return the interaction type with the specified id
    getInteractionType: function(interactionTypeId) {
      return _.find(interactionTypes, { id: interactionTypeId });
    },

    // Create a new interaction and save it on the server
    // interaction.interactionTypeId is the interaction_type_id, interaction.comment is the interaction
    // comment, organizationId is the organization_id of the associated organization, and personId is
    // the receiver of the interaction, or null if this is an anonymous interaction
    // Also, the initiator of the interaction is the currently logged-in user
    recordInteraction: function(interaction, organizationId, personId) {
      // Build up the relationships object
      var relationships = {
        organization: {
          data: { id: organizationId, type: 'organization' },
        },
      };
      if (personId) {
        relationships.receiver = {
          data: { id: personId, type: 'person' },
        };
      }
      var newInteraction = JsonApiDataStore.store.sync({
        data: {
          type: 'interaction',
          attributes: {
            comment: interaction.comment,
            interaction_type_id: interaction.interactionTypeId,
          },
          relationships: relationships,
        },
      });
      var createJson = newInteraction.serialize();
      createJson.included = [
        {
          type: 'interaction_initiator',
          attributes: {
            person_id: loggedInPerson.person.id,
          },
        },
      ];
      return httpProxy
        .post(
          modelsService.getModelMetadata('interaction').url.root,
          createJson,
          {
            errorMessage: 'error.messages.interactions.create_interaction',
          },
        )
        .then(httpProxy.extractModel)
        .then(function(interaction) {
          interaction.initiators.forEach(function(initiator) {
            // Add the new interaction to the person report
            var report = reportsService.lookupPersonReport(
              interaction.organization.id,
              initiator.id,
            );
            reportsService.incrementReportInteraction(
              report,
              interaction.interaction_type_id,
            );
          });

          // Add the new interaction to the organization report
          var report = reportsService.lookupOrganizationReport(
            interaction.organization.id,
          );
          reportsService.incrementReportInteraction(
            report,
            interaction.interaction_type_id,
          );

          // Try to add the interaction to the person's interaction list
          var person = JsonApiDataStore.store.find('person', personId);
          if (person && person.interactions) {
            person.interactions = person.interactions.concat(interaction);
          }

          return interaction;
        });
    },

    updateInteraction: function(interaction) {
      return httpProxy
        .put(
          modelsService
            .getModelMetadata('interaction')
            .url.single(interaction.id),
          interaction.serialize(),
          {
            errorMessage: 'error.messages.interactions.update_interaction',
          },
        )
        .then(httpProxy.extractModel);
    },

    deleteInteraction: function(interaction) {
      return httpProxy.delete(
        modelsService
          .getModelMetadata('interaction')
          .url.single(interaction.id),
        interaction.serialize(),
        {
          errorMessage: 'error.messages.interactions.delete_interaction',
        },
      );
    },
  };
}
