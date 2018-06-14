angular.module('missionhubApp').factory('labelsService', labelsService);

labelsService.$inject = ['httpProxy', 'JsonApiDataStore', 'modelsService', '_'];
function labelsService(httpProxy, JsonApiDataStore, modelsService, _) {
  var labelsService = {
    // Return a label with default field values
    getLabelTemplate: function(orgId) {
      var label = new JsonApiDataStore.Model('label');
      label.setAttribute('name', '');
      label.setRelationship(
        'organization',
        JsonApiDataStore.store.find('organization', orgId),
      );
      return label;
    },

    // Save a new label on the server
    createLabel: function(label) {
      var payload = payloadFromLabel(label);
      return httpProxy
        .post(modelsService.getModelMetadata('label').url.all, payload, {
          errorMessage: 'error.messages.labels.create_label',
        })
        .then(httpProxy.extractModel)
        .then(function(savedLabel) {
          var org = savedLabel.organization;
          if (org && org.labels) {
            org.labels.push(savedLabel);
          }
          return savedLabel;
        });
    },

    // Save an existing label on the server
    updateLabel: function(label) {
      var payload = payloadFromLabel(label);
      return httpProxy
        .put(
          modelsService.getModelMetadata('label').url.single(label.id),
          payload,
          {
            errorMessage: 'error.messages.labels.update_label',
          },
        )
        .then(httpProxy.extractModel);
    },

    // Save a label that may or may not yet exist
    saveLabel: function(label) {
      if (label.id) {
        return labelsService.updateLabel(label);
      }
      return labelsService.createLabel(label);
    },

    // Delete a label on the server
    deleteLabel: function(label) {
      return httpProxy
        .delete(
          modelsService.getModelMetadata('label').url.single(label.id),
          {},
          {
            errorMessage: 'error.messages.labels.delete_label',
          },
        )
        .then(function() {
          var org = label.organization;
          if (org && org.labels) {
            _.pull(org.labels, label);
          }
          return label;
        });
    },

    // Internal methods exposed for testing purposes
    payloadFromLabel: payloadFromLabel,
  };

  // Convert a label into it's JSON API payload
  function payloadFromLabel(label) {
    // Apply the changes
    var includedAttrs = ['name'];
    var relationships = [];
    if (_.isUndefined(label.id)) {
      relationships = ['organization'];
    }
    return {
      data: label.serialize({
        attributes: includedAttrs,
        relationships: relationships,
      }).data,
    };
  }

  return labelsService;
}
