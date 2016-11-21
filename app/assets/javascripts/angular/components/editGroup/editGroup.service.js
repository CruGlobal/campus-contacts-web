(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('editGroupService', editGroupService);

    function editGroupService (groupsService, _) {
        function getTimeOffset () {
            return (new Date().getTimezoneOffset()) * 60 * 1000;
        }

        return {
            // Determine whether a group has valid field values
            isGroupValid: function (group) {
                return group.name && group.location;
            },

            // Return a group with default field values
            getGroupTemplate: function () {
                return {
                    name: '',
                    location: '',
                    meets: 'weekly',
                    meeting_day: '0',
                    start_time: new Date((6 * 60 * 60 * 1000) + getTimeOffset()),
                    end_time: new Date((7 * 60 * 60 * 1000) + getTimeOffset())
                };
            },

            saveGroup: function (group, orgId) {
                var groupParams = _.clone(group);

                groupParams.start_time = (groupParams.start_time.getTime() - getTimeOffset()) / 1000;
                groupParams.end_time = (groupParams.end_time.getTime() - getTimeOffset()) / 1000;

                if (group.meets === 'sporadically') {
                    group.meeting_day = null;
                    group.start_time = null;
                    group.end_time = null;
                }

                return groupsService.createGroup(groupParams, orgId);
            }
        };
    }
})();
