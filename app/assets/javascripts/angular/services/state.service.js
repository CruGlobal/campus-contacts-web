(function() {
    angular
        .module('missionhubApp')
        .factory('state', stateService);

    function stateService(){
        var service = {
            v4_access_token: ''
        };
        return service;
    }
})();
