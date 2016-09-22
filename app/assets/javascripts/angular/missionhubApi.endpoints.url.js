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
            groups: {
                index: '/groups'
            },
            surveys: {
                index: '/surveys'
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
