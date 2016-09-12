(function () {
    angular
        .module('missionhubApp')
        .factory('apiEndPoint', apiEndPointService);

    function apiEndPointService () {
        var endpoints = {
            people: {
                index: '/people',
                me: '/people/me',
                update: '/people/'
            },
            organizations: {
                index: '/organizations'
            },
            reports: {
                people: '/reports/people',
                organizations: '/reports/organizations'
            },
            users: {
                me: '/users/me'
            },
            interactions: {
                post: '/interactions'
            }
        };
        return endpoints;
    }
})();
