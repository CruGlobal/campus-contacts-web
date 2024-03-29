angular.module('campusContactsApp').factory('personProfileService', personProfileService);

function personProfileService($q, JsonApiDataStore, httpProxy, modelsService, _) {
  function updatePerson(personId, params, payload) {
    return httpProxy.put(modelsService.getModelMetadata('person').url.single(personId), payload, {
      params,
      errorMessage: 'error.messages.person_profile.update_person',
    });
  }

  var personProfileService = {
    // Persist attribute changes to a person (including changes to attributes of a person's relationship) on
    // the server
    // "attributes" may either be the name of a single attribute or an array of attribute names
    saveAttribute: function (personId, model, attributes) {
      if (personId === null) {
        // The person is not saved on the server
        return $q.resolve();
      }

      const params = {};

      // Build up the changes object
      const changes = {
        type: model._type,
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
          data: changes,
        });
      }

      // Updates attributes on a person's relation
      return updatePerson(personId, params, {
        data: {
          type: 'person',
        },
        included: [changes],
      }).then(function (res) {
        // If the update resulted in a merge, then reload all of the person's relationships because the
        // person may have new relationships as a result of the merge
        if (res.meta && res.meta.user_merged) {
          return httpProxy.get(
            modelsService.getModelMetadata('person').url.single(personId),
            {},
            {
              errorMessage: 'error.messages.person_profile.reload_merged_person',
            },
          );
        }

        return res;
      });
    },

    // Persist attribute changes to a person's relationship on the server
    // "relationshipName" is the property on the person where the relationship is located
    saveRelationship: function (person, relationship, relationshipName) {
      return personProfileService.saveRelationships(person, [relationship], relationshipName);
    },

    // Persist attribute changes to a person's relationship on the server
    // "relationshipName" is the property on the person where the relationship is located
    saveRelationships: function (person, relationships, relationshipName) {
      if (relationships.length === 0) {
        // Nothing needs to be done
        return $q.resolve();
      }

      if (person.id === null) {
        // The person is not saved on the server, so manually add the relationship to the person instead of
        // saving it on the server
        person[relationshipName] = _.union(person[relationshipName], relationships);
        return $q.resolve();
      }

      return updatePerson(
        person.id,
        { include: relationshipName },
        {
          included: httpProxy.includedFromModels(relationships),
        },
      );
    },

    // Delete a relationship on the server
    deleteRelationship: function (person, relationship, relationshipName) {
      return personProfileService.deleteRelationships(person, [relationship], relationshipName);
    },

    // Delete multiple relationships on the server
    deleteRelationships: function (person, relationships, relationshipName) {
      let deletePromise;
      if (person.id === null) {
        deletePromise = $q.resolve();
      } else {
        // Delete all of the relationships in series
        deletePromise = $q.all(
          relationships.map(function (relationship) {
            return httpProxy.delete(
              modelsService.getModelUrl(relationship),
              {},
              {
                errorMessage: 'error.messages.person_profile.delete_relationships',
              },
            );
          }),
        );
      }

      return deletePromise.then(function () {
        // Manually remove the models from the person's relationships
        person[relationshipName] = _.difference(person[relationshipName], relationships);
      });
    },

    // Assign contacts to a person
    addAssignments: function (person, organizationId, contacts) {
      const assignments = contacts.map(function (contact) {
        const model = new JsonApiDataStore.Model('contact_assignment');
        model.setAttribute('assigned_to_id', contact.id);
        model.setAttribute('organization_id', organizationId);
        model.setRelationship('assigned_to', contact);
        model.setRelationship('organization', JsonApiDataStore.store.find('organization', organizationId));
        return model;
      });

      return personProfileService.saveRelationships(person, assignments, 'reverse_contact_assignments');
    },

    // Unassign contacts from a person
    removeAssignments: function (person, contacts) {
      const contactIds = _.map(contacts, 'id');
      const deletePromises = _.chain(person.reverse_contact_assignments)
        .filter(function (assignment) {
          return httpProxy.isLoaded(assignment) && _.includes(contactIds, assignment.assigned_to.id);
        })
        .map(function (assignment) {
          return personProfileService.deleteRelationship(person, assignment, 'reverse_contact_assignments');
        })
        .value();
      return $q.all(deletePromises);
    },

    // Transform an address into an array of address lines for display in the UI
    formatAddress: function (address) {
      const lineParts = [
        { content: address.city, prefix: null },
        { content: address.state, prefix: ', ' },
        { content: address.zip, prefix: ' ' },
      ];

      // Essentially what we are doing here is joining each of the line parts but using a different delimiter
      // for each line part
      // See the specs for examples of how this function will generate region lines from addresses
      const regionLine = _.filter(lineParts, 'content').reduce(function (regionLine, part) {
        // Append the prefix to the line unless the line is empty (because the line should not start with a
        // part prefix)
        // Then append the part content to the line
        return regionLine + (regionLine ? part.prefix : '') + part.content;
      }, '');

      return [
        address.address1,
        address.address2,
        address.address3,
        address.address4,
        regionLine,

        // Only show the country line if the country is outside of the US
        address.country === 'US' ? null : address.country,
      ].filter(_.identity);
    },

    unarchive: function (permission) {
      return updatePerson(
        permission.person_id,
        { include: 'organizational_permissions' },
        {
          included: [
            {
              type: 'organizational_permission',
              id: permission.id,
              attributes: {
                archive_date: null,
              },
            },
          ],
        },
      );
    },
  };

  return personProfileService;
}
