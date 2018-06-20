angular.module('missionhubApp').factory('editGroupService', editGroupService);

function editGroupService() {
    return {
        // Determine whether a group has valid field values
        isGroupValid: function(group) {
            return group.name && group.location;
        },
    };
}
