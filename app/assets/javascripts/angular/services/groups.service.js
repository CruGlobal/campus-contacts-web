(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('groupsService', groupsService);

    function groupsService (httpProxy, modelsService) {
        // Convert a group into it's JSON API payload
        function payloadFromGroup (group) {
            var includedAttrs = ['name', 'location', 'meets', 'meeting_day', 'start_time', 'end_time'];
            return group.serialize({ attributes: includedAttrs });
        }

        var groupsService = {
            // Save a new group on the server
            createGroup: function (group) {
                var payload = payloadFromGroup(group);
                return httpProxy.post(modelsService.getModelMetadata('group').url.all, payload, {
                    errorMessage: 'error.messages.groups.create_group'
                })
                    .then(httpProxy.extractModel)
                    .then(function (group) {
                        var org = group.organization;
                        if (org && org.groups) {
                            org.groups.push(group);
                        }
                        return group;
                    });
            },

            // Save an existing group on the server
            updateGroup: function (group) {
                var payload = payloadFromGroup(group);
                return httpProxy.put(modelsService.getModelMetadata('group').url.single(group.id), payload, {
                    errorMessage: 'error.messages.groups.update_group'
                }).then(httpProxy.extractModel);
            },

            saveGroup: function (group) {
                if (group.id) {
                    return groupsService.updateGroup(group);
                }
                return groupsService.createGroup(group);
            }
        };

        return groupsService;
    }
})();
