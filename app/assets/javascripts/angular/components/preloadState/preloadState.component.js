angular.module('campusContactsApp').component('preloadState', {
  controller: preloadStateController,
  bindings: {
    name: '@',
    data: '@',
  },
});

function preloadStateController(state, $http) {
  const vm = this;

  vm.$onInit = activate;

  function activate() {
    if (vm.data === 'true' || vm.data === 'false') {
      state[vm.name] = vm.data === 'true';
    } else {
      state[vm.name] = vm.data;
    }
    addAuthHeader();
  }

  function addAuthHeader() {
    if (vm.name === 'v4AccessToken') {
      $http.defaults.headers.common.Authorization = 'Bearer ' + state.v4AccessToken;
    }
  }
}
