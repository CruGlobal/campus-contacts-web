(function(){
    angular
        .module('missionhubApp')
        .component('myContactsDashboard', {
            controller: angularTestController,
            templateUrl: '/templates/myContactsDashboard.html'
        });

    function angularTestController($http, state) {
        var vm = this;
        vm.contacts = [];
        vm.loading = true;

        vm.retry = activate;

        activate();

        function activate() {
            $http.get('http://localhost:3001/apis/v4/people?access_token=' + state.v4_access_token)
                 .then(function (request) {
                     var store = new JsonApiDataStore();
                     store.sync(request.data);
                     vm.contacts = store.findAll('person');
                     console.log(vm.contacts);
                     vm.loading = false;
                 })
        }
    }
})();