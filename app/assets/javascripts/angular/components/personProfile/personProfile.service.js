(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('personProfileService', personProfileService);

    function personProfileService (httpProxy, modelsService, $q, _) {
        function updatePerson (personId, params, payload) {
            return httpProxy.put(modelsService.getModelMetadata('person').url.single(personId), payload, {
                params: params
            });
        }

        return {
            // Persist attribute changes to a person (including changes to attributes of a person's relationship) on
            // the server
            // "attributes" may either be the name of a single attribute or an array of attribute names
            saveAttribute: function (personId, model, attributes) {
                var params = {};

                // Build up the changes object
                var changes = {
                    type: model._type
                };

                if (model.id) {
                    // We are updating an existing model

                    changes.id = model.id;

                    // Persist only the specified attributes
                    changes.attributes = _.pick(model, attributes);
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

            // Assign contacts to a person
            addAssignments: function (person, organizationId, contacts) {
                if (contacts.length === 0) {
                    return $q.resolve();
                }

                return httpProxy.put(modelsService.getModelUrl(person), {
                    data: {
                        type: 'person'
                    },
                    included: contacts.map(function (contact) {
                        return {
                            type: 'contact_assignment',
                            attributes: {
                                assigned_to_id: contact.id,
                                organization_id: organizationId
                            }
                        };
                    })
                }, {
                    params: {
                        include: 'reverse_contact_assignments'
                    }
                });
            },

            // Unassign contacts from a person
            removeAssignments: function (person, contact) {
                var contactIds = _.map(contact, 'id');
                var contactAssignments = person.reverse_contact_assignments.filter(function (contactAssignment) {
                    return httpProxy.isLoaded(contactAssignment) &&
                        _.includes(contactIds, contactAssignment.assigned_to.id);
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
            },

            // Transform an address into an array of address lines for display in the UI
            formatAddress: function (address) {
                var lineParts = [
                    { content: address.city, prefix: null },
                    { content: address.state, prefix: ', ' },
                    { content: address.zip, prefix: ' ' }
                ];

                // Essentially what we are doing here is joining each of the line parts but using a different delimiter
                // for each line part
                // See the specs for examples of how this function will generate region lines from addresses
                var regionLine = _.filter(lineParts, 'content').reduce(function (regionLine, part) {
                    // Append the prefix to the line unless the line is empty (because the line should not start with a
                    // part prefix)
                    // Then append the part content to the line
                    return regionLine + (regionLine ? part.prefix : '') + part.content;
                }, '');

                return [
                    address.address1, address.address2, address.address3, address.address4,
                    regionLine,

                    // Only show the country line if the country is outside of the US
                    address.country === 'US' ? null : address.country
                ].filter(_.identity);
            }
        };
    }
})();
