angular
    .module('missionhubApp')
    .factory('permissionService', permissionService);

// This service contains action logic that is shared across components
function permissionService () {
    return {
        adminId: 1,
        noPermissionId: 2,
        userId: 4,
        adminAndUserIds: [1, 4]
    };
}
