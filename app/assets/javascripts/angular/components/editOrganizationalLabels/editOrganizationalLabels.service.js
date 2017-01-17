(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('editOrganizationalLabelsService', editOrganizationalLabelsService);

    function editOrganizationalLabelsService ($q, httpProxy, modelsService, _) {
        function updatePerson (personId, params, payload) {
            return httpProxy.put(modelsService.getModelMetadata('person').url.single(personId), payload, {
                params: params
            });
        }

        function pushNewLabels (person, organizationId, newLabelIds) {
            var includedObjects = _.map(newLabelIds, function (labelId) {
                return {
                    type: 'organizational_label',
                    attributes: {
                        organization_id: organizationId,
                        label_id: labelId
                    }
                };
            });
            return updatePerson(person.id, { include: 'organizational_labels' }, {
                included: includedObjects
            });
        }

        function deleteOrgLabel (orgLabel, person) {
            return httpProxy
                .delete(modelsService.getModelMetadata('organizational_label').url.single(orgLabel.id))
                .then(function () {
                    _.pull(person.organizational_labels, orgLabel);
                });
        }

        return {
            saveOrganizationLabels: function (person, selectedLabels, organizationId) {
                var newLabels = _.omitBy(selectedLabels, function (value, labelId) {
                    // omit if the selected label is already on the person at this organization
                    return !value || _.find(person.organizational_labels, function (orgLabel) {
                        return orgLabel.organization_id === organizationId && orgLabel.label.id === labelId;
                    });
                });
                var newLabelIds = _.keys(newLabels);
                var promises = [];
                _.forEach(person.organizational_labels, function (orgLabel) {
                    if (orgLabel.organization_id === organizationId && !selectedLabels[orgLabel.label.id]) {
                        promises.push(deleteOrgLabel(orgLabel, person));
                    }
                });
                if (newLabelIds.length > 0) {
                    promises.push(pushNewLabels(person, organizationId, newLabelIds));
                }
                return $q.all(promises);
            }
        };
    }
})();
