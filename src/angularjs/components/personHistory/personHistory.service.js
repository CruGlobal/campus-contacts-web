angular
    .module('missionhubApp')
    .factory('personHistoryService', personHistoryService);

function personHistoryService (_) {
    return {
        // Build the history feed (interactions and completed surveys) for a person
        // feedFilter is a string and must have the value 'interactions', 'notes', 'surveys', or 'all'
        buildHistoryFeed: function (person, feedFilter, orgId) {
            return _.sortBy(
                filterHistoryByType(person, feedFilter, orgId),
                getHistorySortKey
            );
        }
    };

    function filterHistoryByType (person, feedFilter, orgId) {
        switch (feedFilter) {
            case 'interactions':
                return filterInteractionByOrg(person.interactions, orgId)
                    .filter(function (interaction) {
                        return interaction.interaction_type_id !== 1;
                    });
            case 'notes':
                return _.filter(
                    filterInteractionByOrg(person.interactions, orgId),
                    { interaction_type_id: 1 }
                );
            case 'surveys':
                return filterSurveyByOrg(person.answer_sheets, orgId);
            case 'all':
                return [].concat(
                    filterInteractionByOrg(person.interactions, orgId),
                    filterSurveyByOrg(person.answer_sheets, orgId)
                );
        }
    }

    function filterInteractionByOrg (history, orgId) {
        return _.filter(history, ['organization.id', orgId]);
    }

    function filterSurveyByOrg (history, orgId) {
        return _.filter(history, ['survey.organization_id', orgId]);
    }

    function getHistorySortKey (item) {
        // Pick the sort key based on whether the item is an interaction or an answer sheet
        switch (item._type) {
            case 'interaction':
                return item.timestamp;
            case 'answer_sheet':
                // Default to an empty string so that answer sheets without a date will appear first
                return item.completed_at || '';
        }
    }
}
