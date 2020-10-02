angular
    .module('campusContactsApp')
    .factory('personSelectionService', personSelectionService);

function personSelectionService(_) {
    var personSelectionService = {
        // Return a boolean indicating whether a selection contains people that are not included in the id list
        containsUnincludedPeople: function (selection) {
            // The selection contains unincluded people when all people are selected and not all of those people
            // are included in the person id list
            return selection.allSelected && !selection.allIncluded;
        },

        // Convert a filters object into the form expected by the server-side API
        convertToFilters: function (selection) {
            if (!personSelectionService.containsUnincludedPeople(selection)) {
                // Use the id filters when we have the ids of all the people who are selected
                return {
                    ids: (selection.selectedPeople || []).join(','),
                };
            }

            // Use the filters when all people are selected
            var filters = selection.filters;
            return _.pickBy({
                organization_ids: selection.orgId,
                exclude_ids: (selection.unselectedPeople || []).join(','),
                assigned_tos: (filters.assignedTos || []).join(','),
                label_ids: (filters.labels || []).join(','),
                group_ids: (filters.groups || []).join(','),
                name: filters.searchString || '',
                statuses: filters.statuses,
                genders: filters.genders,
                permissions: filters.permissions,
                include_archived: filters.includeArchived,
                ...(selection.surveyId ||
                filters.questions ||
                filters.answerMatchingOptions
                    ? {
                          answer_sheets: {
                              survey_ids: selection.surveyId,
                              answers: {
                                  ...filters.questions,
                              },
                              answers_options: {
                                  ...filters.answerMatchingOptions,
                              },
                          },
                      }
                    : {}),
            });
        },
    };

    return personSelectionService;
}
