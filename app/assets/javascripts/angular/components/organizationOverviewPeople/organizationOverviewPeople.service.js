angular
    .module('missionhubApp')
    .factory(
        'organizationOverviewPeopleService',
        organizationOverviewPeopleService,
    );

function organizationOverviewPeopleService(
    ProgressiveListLoader,
    RequestDeduper,
    peopleScreenService,
) {
    return {
        listLoader: new ProgressiveListLoader({
            modelType: 'person',
            requestDeduper: new RequestDeduper(),
            errorMessage:
                'error.messages.organization_overview_people.load_people_chunk',
        }),
        buildListParams: (orgId, filters = {}, orderParam = []) => ({
            include: [
                'phone_numbers',
                'email_addresses',
                'organizational_permissions',
                'reverse_contact_assignments',
            ].join(','),
            sort: peopleScreenService.buildOrderString(orderParam),
            'filters[organization_ids]': orgId,
            ...(filters.searchString
                ? {
                      'filters[name]': filters.searchString,
                  }
                : {}),
            ...(filters.includeArchived
                ? {
                      'filters[include_archived]': true,
                  }
                : {}),
            ...(filters.labels
                ? {
                      'filters[label_ids]': filters.labels.join(','),
                  }
                : {}),
            ...(filters.assignedTos
                ? {
                      'filters[assigned_tos]': filters.assignedTos.join(','),
                  }
                : {}),
            ...(filters.groups
                ? {
                      'filters[group_ids]': filters.groups.join(','),
                  }
                : {}),
        }),
    };
}
