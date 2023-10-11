angular.module('campusContactsApp').factory('state', stateService);

function stateService() {
  const service = {
    v4AccessToken: '',
  };
  return service;
}
