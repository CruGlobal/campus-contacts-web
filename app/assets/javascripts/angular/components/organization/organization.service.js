(function () {
    angular
        .module('missionhubApp')
        .factory('organizationService', organizationService);

    function organizationService (_) {
        return {
            incrementReportInteraction: function (report, interactionTypeId) {
                var interaction = _.find(report.interactions, {
                    interaction_type_id: interactionTypeId
                });
                if (angular.isDefined(interaction)) {
                    interaction.interaction_count++;
                } else {
                    report.interactions.push({
                        interaction_type_id: interactionTypeId,
                        interaction_count: 1
                    });
                }
            }
        };
    }
})();
