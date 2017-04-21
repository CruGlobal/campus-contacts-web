(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('editGroupService', editGroupService);

    function editGroupService (JsonApiDataStore, groupsService, moment) {
        return {
            // Convert a time in milliseconds since midnight into a JavaScript Date object
            timeToDate: function (time) {
                return moment()
                    .startOf('day')
                    .milliseconds(time)
                    .toDate();
            },

            // Convert a JavaScript Date object into a time in milliseconds since midnight
            dateToTime: function (date) {
                return moment(date).diff(moment(date).startOf('day'));
            },

            // Determine whether a group has valid field values
            isGroupValid: function (group) {
                return group.name && group.location;
            },

            // Return a group with default field values
            getGroupTemplate: function (orgId) {
                var group = new JsonApiDataStore.Model('group');
                group.setAttribute('name', '');
                group.setAttribute('location', '');
                group.setAttribute('meets', 'weekly');
                group.setAttribute('meeting_day', '0');
                group.setAttribute('start_time', 6 * 60 * 60 * 1000);
                group.setAttribute('end_time', 7 * 60 * 60 * 1000);
                group.setRelationship('organization', JsonApiDataStore.store.find('organization', orgId));
                return group;
            },

            saveGroup: function (group, orgId) {
                if (group.meets === 'sporadically') {
                    group.meeting_day = null;
                    group.start_time = null;
                    group.end_time = null;
                }

                return groupsService.saveGroup(group, orgId);
            }
        };
    }
})();
