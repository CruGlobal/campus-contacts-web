angular
    .module('missionhubApp')
    .factory('myPeopleDashboardService', myPeopleDashboardService);

function myPeopleDashboardService(httpProxy, modelsService, _) {
    var myPeopleDashboardService = {
        isMobile: () =>
            window.navigator.userAgent.match(
                /Android|webOS|iPhone|iPad|iPod|BlackBerry|Windows Phone/i,
            ),

        loadPeople: function(params) {
            return httpProxy.get(
                modelsService.getModelMetadata('person').url.all,
                params || {},
                {
                    errorMessage:
                        'error.messages.my_people_dashboard.load_people',
                },
            );
        },

        loadOrganizations: function(params) {
            return httpProxy
                .get(
                    modelsService.getModelMetadata('organization').url.all,
                    _.extend(
                        {
                            sort: '-active_people_count',
                            include: '',
                            'page[limit]': 100,
                            'filters[user_created]': false,
                        },
                        params,
                    ),
                    {
                        errorMessage:
                            'error.messages.my_people_dashboard.load_orgs',
                    },
                )
                .then(httpProxy.extractModels);
        },
    };

    return myPeopleDashboardService;
}
