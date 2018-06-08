angular
  .module('missionhubApp')
  .factory('organizationOverviewService', organizationOverviewService);

function organizationOverviewService(
  $q,
  httpProxy,
  modelsService,
  organizationOverviewPeopleService,
  organizationOverviewTeamService,
  organizationOverviewSuborgsService,
  _,
) {
  return {
    // Load an organization's relationships (groups and surveys)
    loadOrgRelations: function(org) {
      // Determine which relations are not yet loaded
      var include = ['groups', 'surveys'].filter(function(relation) {
        // Include this relation only if contains placeholder relations that need to be fully loaded
        return _.findIndex(org[relation], { _placeHolder: true }) !== -1;
      });

      // Load the missing relations, if any
      if (include.length === 0) {
        return $q.resolve();
      }
      return httpProxy.get(
        modelsService.getModelUrl(org),
        {
          include: include.join(','),
        },
        {
          errorMessage:
            'error.messages.organization_overview.load_org_relationships',
        },
      );
    },

    getSubOrgCount: function(org) {
      return organizationOverviewSuborgsService.loadOrgSubOrgCount(org.id);
    },

    // Return a promise that resolves to the number of people in an organization
    getPersonCount: function(org) {
      return organizationOverviewPeopleService.loadOrgPeopleCount(org.id);
    },

    // Return a promise that resolves to the number of team members in an organization
    getTeamCount: function(org) {
      return organizationOverviewTeamService.loadOrgTeamCount(org.id);
    },
  };
}
