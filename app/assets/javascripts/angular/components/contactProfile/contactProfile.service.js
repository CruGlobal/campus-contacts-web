(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('contactProfileService', contactProfileService);

    function contactProfileService (httpProxy, modelsService, $q, _) {
        function updatePerson (personId, params, payload) {
            return httpProxy.put(modelsService.getModelMetadata('person').url.single(personId), payload, {
                params: params
            });
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
                return httpProxy.delete(modelsService.getModelUrl(model));
            },

            // Assign people to a person
            addAssignments: function (person, organizationId, people) {
                if (people.length === 0) {
                    return $q.resolve();
                }

                return httpProxy.put(modelsService.getModelUrl(person), {
                    data: {
                        type: 'person'
                    },
                    included: people.map(function (person) {
                        return {
                            type: 'contact_assignment',
                            attributes: {
                                assigned_to_id: person.id,
                                organization_id: organizationId
                            }
                        };
                    })
                });
            },

            // Unassign people from a person
            removeAssignments: function (person, people) {
                var peopleIds = _.map(people, 'id');
                var contactAssignments = person.reverse_contact_assignments.filter(function (contactAssignment) {
                    return httpProxy.isLoaded(contactAssignment) &&
                        _.includes(peopleIds, contactAssignment.assigned_to.id);
                });

                function deleteContactAssignment (contactAssignment) {
                    return httpProxy.delete(modelsService.getModelUrl(contactAssignment));
                }

                // Delete the contact assignments in parallel
                return $q.all(contactAssignments.map(deleteContactAssignment)).then(function () {
                    // Remove the deleted contact assignments from memory
                    person.reverse_contact_assignments = _.difference(person.reverse_contact_assignments,
                                                                      contactAssignments);
                });
            }
        };
    }
})();
