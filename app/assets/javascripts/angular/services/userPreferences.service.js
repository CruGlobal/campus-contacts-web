angular.module('campusContactsApp').factory('userPreferencesService', userPreferencesService);

function userPreferencesService(httpProxy, modelsService, loggedInPerson, _) {
  const factory = {
    organizationOrderChange,
    toggleOrganizationVisibility,
    applyUserOrgDisplayPreferences,
    _updateUserPreferences: updateUserPreferences,
  };

  return factory;

  function organizationOrderChange(organizations) {
    const orgOrder = _.map(organizations, 'id');
    factory._updateUserPreferences(
      {
        organization_order: orgOrder,
      },
      'error.messages.my_people_dashboard.update_org_order',
    );
  }

  function toggleOrganizationVisibility(organization) {
    organization.visible = !organization.visible;

    let hiddenOrgs = loggedInPerson.person.user.hidden_organizations || [];
    if (organization.visible) {
      // The organization is now visible, so remove it from the user's list of hidden organizations
      hiddenOrgs = _.remove(hiddenOrgs, organization.id);
    } else {
      // The organization is now hidden, so add it to the user's list of hidden organizations
      hiddenOrgs.push(organization.id);
    }

    // Commit the changes
    factory._updateUserPreferences(
      {
        hidden_organizations: hiddenOrgs,
      },
      'error.messages.my_people_dashboard.update_org_visibility',
    );
  }

  function applyUserOrgDisplayPreferences(organizations) {
    // For a given org, map the org id to the sort key
    const orgOrderPreference = _.invert(loggedInPerson.person.user.organization_order);

    const partitionedOrgs = _.reduce(
      organizations,
      function (result, org) {
        // Update org visible flag
        org.visible = !_.includes(loggedInPerson.person.user.hidden_organizations, org.id.toString());

        const userPreferredOrgKey = orgOrderPreference[org.id];
        if (userPreferredOrgKey) {
          // if sort key found put it at that index
          result.userPreferredOrgs[userPreferredOrgKey] = org;
        } else {
          // otherwise put it in otherOrgs to sort later
          result.otherOrgs.push(org);
        }
        return result;
      },
      {
        userPreferredOrgs: [],
        otherOrgs: [],
      },
    );

    // Result is user ordered orgs first and then the rest ordered by ancestry then by name
    return _.concat(
      _.compact(partitionedOrgs.userPreferredOrgs),
      _.orderBy(partitionedOrgs.otherOrgs, ['ancestry', 'name']),
    );
  }

  function updateUserPreferences(changedPreferences, errorMessage) {
    return httpProxy.put(
      modelsService.getModelMetadata('user').url.single('me'),
      {
        data: {
          type: 'user',
          attributes: changedPreferences,
        },
      },
      {
        errorMessage,
      },
    );
  }
}
