angular.module('campusContactsApp').factory('state', stateService);

function stateService() {
    var service = {
        v4AccessToken: '',
    };
    return service;
}
