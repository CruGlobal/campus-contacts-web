angular
    .module('missionhubApp')
    .factory('assignedAltSelectService', assignedAltSelectService);

function assignedAltSelectService(httpProxy) {
    return {
        // Get all the labels from the current organizations
        searchLabels: (query, organizationId) => {
            return httpProxy
                .get(
                    `/organizations/${organizationId}`,
                    {
                        include: 'labels',
                    },
                    {
                        errorMessage: 'error.messages.surveys.loadQuestions',
                    },
                )
                .then(data => {
                    return data.data.labels;
                });
        },
    };
}
