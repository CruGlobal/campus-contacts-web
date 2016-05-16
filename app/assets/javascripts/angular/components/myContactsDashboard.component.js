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
                     vm.contacts = request.data.data;
                     console.log(request.data.data);
                     vm.loading = false;
                 })
        }
    }
})();