(function () {

    'use strict';

    angular
        .module('missionhubApp')
        .factory('contactProfileService', contactProfileService);

    function contactProfileService (httpProxy, modelsService, _) {
        function updatePerson (personId, params, payload) {
            return httpProxy.put(modelsService.getModelMetadata('person').url.single(personId), params, payload);
        }

        return {
            // Persist attribute changes to a person (including changes to attributes of a person's relationship) on
            // the server
            saveAttribute: function (personId, model, attribute) {
                var params = {};

                // Build up the changes object
                var changes = {
                    type: model._type
                };

                if (model.id) {
                    // We are updating an existing model

                    changes.id = model.id;
                    // Persist only the one attribute
                    changes.attributes = _.fromPairs([
                        [attribute, model[attribute]]
                    ]);
                } else {
                    // We are creating a new model

                    // Persist all model fields
                    changes.attributes = model;

                    // Include the relationship so that the newly-created model will be loaded and not be a placeholder
                    params.include = modelsService.getModelMetadata(model._type).include;
                }

                // Update attributes on a person
                if (model._type === 'person') {
                    return updatePerson(personId, params, {
                        data: changes
                    });
                }

                // Updates attributes on a person's relation
                return updatePerson(personId, params, {
                    data: {
                        type: 'person'
                    },
                    included: [changes]
                });
            },

            // Delete a model on the server
            deleteModel: function (model) {
                return httpProxy.delete(modelsService.getModelMetadata(model._type).url.single(model.id));
            }
        };
    }

})();
