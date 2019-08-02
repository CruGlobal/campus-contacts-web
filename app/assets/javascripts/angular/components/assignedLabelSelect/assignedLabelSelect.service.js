angular
    .module('missionhubApp')
    .factory('assignedLabelSelectService', assignedLabelSelectService);

function assignedLabelSelectService(httpProxy) {
    return {
        // Get all the labels from the current organizations
        searchLabels: organizationId => {
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
