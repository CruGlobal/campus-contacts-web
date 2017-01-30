(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('editGroupOrLabelAssignmentsService', editGroupOrLabelAssignmentsService);

    function editGroupOrLabelAssignmentsService ($q, httpProxy, modelsService, _) {
        function updatePerson (personId, params, payload) {
            return httpProxy.put(modelsService.getModelMetadata('person').url.single(personId), payload, {
                params: params
            });
        }

        function pushNew (modelType, person, newIds, organizationId) {
            var includedObjects = _.map(newIds, function (labelId) {
                return buildRelationshipObject(modelType, labelId, organizationId);
            });
            return updatePerson(person.id, { include: personRelationshipName(modelType) }, {
                included: includedObjects
            });
        }

        function buildRelationshipObject (modelType, relatedId, organizationId) {
            var json = {
                type: modelType,
                attributes: {}
            };
            if (modelType === 'organizational_label') {
                json.attributes.label_id = relatedId;
                json.attributes.organization_id = organizationId;
            } else {
                json.attributes.group_id = relatedId;
            }
            return json;
        }

        function deleteModel (model, person) {
            var url = modelsService.getModelMetadata(model._type).url.single(model.id);
            return httpProxy.delete(url).then(function () {
                _.pull(person[personRelationshipName(model)], model);
            });
        }

        function personRelationshipName (model) {
            // accept either a string type or an object
            var type = _.isString(model) ? model : model._type;
            return type === 'organizational_label' ?
                'organizational_labels' :
                'group_memberships';
        }

        function relatedModel (type) {
            return type === 'organizational_label' ? 'label' : 'group';
        }

        function deleteByRelatedId (type, relatedId, person) {
            var relationship = person[personRelationshipName(type)];
            var relatedType = relatedModel(type);
            var relationshipModel = _.find(relationship, [relatedType + '.id', relatedId]);
            return deleteModel(relationshipModel, person);
        }

        function saveRelationshipChanges (type, person,
                                          newRelationshipIds, oldRelationshipIds,
                                          organizationId) {
            var promises = _.map(oldRelationshipIds, function (relatedId) {
                return deleteByRelatedId(type, relatedId, person);
            });
            if (newRelationshipIds.length > 0) {
                promises.push(pushNew(type, person, newRelationshipIds, organizationId));
            }
            return $q.all(promises);
        }

        return {
            saveOrganizationalLabels: function (person, organizationId, newLabelIds, oldLabelIds) {
                return saveRelationshipChanges('organizational_label',
                                               person, newLabelIds, oldLabelIds, organizationId);
            },

            saveGroupMemberships: function (person, newGroupIds, oldGroupIds) {
                return saveRelationshipChanges('group_membership',
                                               person, newGroupIds, oldGroupIds);
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
