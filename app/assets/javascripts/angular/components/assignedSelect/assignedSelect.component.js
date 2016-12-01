(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('assignedSelect', {
            bindings: {
                assigned: '=',
                organizationId: '<'
            },
            controller: assignedSelectController,
            templateUrl: '/assets/angular/components/assignedSelect/assignedSelect.html'
        });

    function assignedSelectController ($scope, assignedSelectService, $q) {
        var vm = this;
        vm.people = [];
        vm.isMe = assignedSelectService.isMe;
        vm.$onInit = activate;

        function activate () {
            var nextRequestStart = $q.defer();

            // Refresh the person list whenever the search term changes
            $scope.$watch('$select.search', function (search) {
                if (search === '') {
                    // Ignore empty searches
                    vm.people = [];
                    return;
                }

                // This request should timeout when the next search request starts (if this request has not already)
                // completed so that only one search request is in progress at a time.

                // Inform the previous request that another request is starting, which will abort it if it has not
                // already completed
                nextRequestStart.resolve();

                // Create a new deferred that will be resolved by the next request
                nextRequestStart = $q.defer();

                // Look for people in the current organization that match the new search term
                assignedSelectService.searchPeople(search, vm.organizationId, {
                    timeout: nextRequestStart.promise
                }).then(function (people) {
                    vm.people = people;
                });
            });
        }
    }
})();
