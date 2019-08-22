angular
    .module('missionhubApp')
    .factory('myPeopleDashboardService', myPeopleDashboardService);

function myPeopleDashboardService(httpProxy, modelsService, _) {
    var myPeopleDashboardService = {
        // Check for whether the user is on mobile or not
        isMobile: () => {
            if (
                navigator.userAgent.match(/Android/i) ||
                navigator.userAgent.match(/webOS/i) ||
                navigator.userAgent.match(/iPhone/i) ||
                navigator.userAgent.match(/iPad/i) ||
                navigator.userAgent.match(/iPod/i) ||
                navigator.userAgent.match(/BlackBerry/i) ||
                navigator.userAgent.match(/Windows Phone/i)
            ) {
                return true;
            } else {
                return false;
            }
        },
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
