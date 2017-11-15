angular
    .module('missionhubApp')
    .factory('state', stateService);

function stateService () {
    var service = {
        v4AccessToken: ''
    };
    return service;
}
