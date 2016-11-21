(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('groupsService', groupsService);

    function groupsService (httpProxy, modelsService, JsonApiDataStore, _) {
        return {
            createGroup: function (group, organizationId) {
                // Build up the relationships object
                var relationships = {
                    organization: {
                        data: { id: organizationId, type: 'organization' }
                    }
                };
                var includedAttrs = ['name', 'location', 'meets', 'meeting_day', 'start_time', 'end_time'];
                var newGroup = JsonApiDataStore.store.sync({
                    data: {
                        type: 'group',
                        attributes: _.pick(group, includedAttrs),
                        relationships: relationships
                    }
                });
                var createJson = newGroup.serialize();
                return httpProxy.post(modelsService.getModelMetadata('group').url.root, null, createJson)
                    .then(httpProxy.extractModel);
            }
        };
    }
})();
