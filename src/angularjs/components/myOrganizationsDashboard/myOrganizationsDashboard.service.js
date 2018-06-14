myOrganizationsDashboardService.$inject = [
  'JsonApiDataStore',
  'loggedInPerson',
  'permissionService',
  '_',
];
angular
  .module('missionhubApp')
  .factory('myOrganizationsDashboardService', myOrganizationsDashboardService);

function myOrganizationsDashboardService(
  JsonApiDataStore,
  loggedInPerson,
  permissionService,
  _,
) {
  return {
    // Return an array of all loaded root organizations
    getRootOrganizations: function() {
      // Find all of the organizations that the user is a team member of
      return _
        .chain(JsonApiDataStore.store.findAll('organizational_permission'))
        .filter(function(permission) {
          return (
            permission.person_id === loggedInPerson.person.id &&
            _.includes(
              permissionService.adminAndUserIds,
              permission.permission_id,
            )
          );
        })
        .map('organization')
        .value();
    },
  };
}
