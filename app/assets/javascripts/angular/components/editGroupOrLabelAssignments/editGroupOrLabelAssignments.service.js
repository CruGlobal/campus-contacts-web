(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('editGroupOrLabelAssignmentsService', editGroupOrLabelAssignmentsService);

    function editGroupOrLabelAssignmentsService ($q, httpProxy, modelsService, JsonApiDataStore,
                                                 personProfileService, _) {
        function pushNew (modelType, person, newIds, organizationId) {
            var relationships = _.map(newIds, function (labelId) {
                return buildRelationshipModel(modelType, labelId, organizationId);
            });

            return personProfileService.saveRelationships(person, relationships, personRelationshipName(modelType));
        }

        function buildRelationshipModel (modelType, relatedId, organizationId) {
            var model = new JsonApiDataStore.Model(modelType);
            if (modelType === 'organizational_label') {
                model.setAttribute('label_id', relatedId);
                model.setAttribute('organization_id', organizationId);
                model.setRelationship('label', JsonApiDataStore.store.find('label', relatedId));
            } else {
                model.setAttribute('group_id', relatedId);
                model.setRelationship('group', JsonApiDataStore.store.find('group', relatedId));
            }
            return model;
        }

        function personRelationshipName (modelType) {
            // accept either a string type or an object
            return modelType === 'organizational_label' ?
                'organizational_labels' :
                'group_memberships';
        }

        function relatedModel (type) {
            return type === 'organizational_label' ? 'label' : 'group';
        }

        function deleteByRelatedId (type, relatedId, person) {
            var relationshipName = personRelationshipName(type);
            var relatedType = relatedModel(type);
            var relationship = _.find(person[relationshipName], [relatedType + '.id', relatedId]);
            return personProfileService.deleteRelationship(person, relationship, relationshipName);
        }

        function saveRelationshipChanges (type, person,
                                          addedRelationshipIds, removedRelationshipIds,
                                          organizationId) {
            var promises = _.map(removedRelationshipIds, function (relatedId) {
                return deleteByRelatedId(type, relatedId, person);
            });
            if (addedRelationshipIds.length > 0) {
                promises.push(pushNew(type, person, addedRelationshipIds, organizationId));
            }
            return $q.all(promises);
        }

        return {
            saveOrganizationalLabels: function (person, organizationId, addedLabelIds, removedLabelIds) {
                return saveRelationshipChanges('organizational_label',
                                               person, addedLabelIds, removedLabelIds, organizationId);
            },

            saveGroupMemberships: function (person, addedGroupIds, removedGroupIds) {
                return saveRelationshipChanges('group_membership',
                                               person, addedGroupIds, removedGroupIds);
            },

            loadPlaceholderEntries: function (entries, orgId) {
                if (_.find(entries, { _placeHolder: true })) {
                    httpProxy.get(modelsService.getModelMetadata('organization').url.single(orgId), {
                        include: modelsService.getModelMetadata(entries[0]._type).include
                    });
                }
            }
        };
    }
})();
