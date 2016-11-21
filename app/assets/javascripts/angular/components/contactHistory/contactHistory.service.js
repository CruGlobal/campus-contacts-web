(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('contactHistoryService', contactHistoryService);

    function contactHistoryService (_) {
        return {
            // Build the history feed (interactions and completed surveys) for a person
            // feedFilter is a string and must have the value 'notes', 'surveys', or 'all'
            buildHistoryFeed: function (person, feedFilter) {
                return _.sortBy({
                    notes: person.interactions,
                    surveys: person.answer_sheets,
                    all: [].concat(person.interactions, person.answer_sheets)
                }[feedFilter], function (item) {
                    // Pick the sort key based on whether the item is an interaction or an answer sheet
                    if (item._type === 'interaction') {
                        return item.timestamp;
                    }
                    if (item._type === 'answer_sheet') {
                        // Default to an empty string so that answer sheets without a date will appear first
                        return item.completed_at || '';
                    }
                });
            }
        };
    }
})();
