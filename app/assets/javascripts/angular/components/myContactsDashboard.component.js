(function(){
    'use strict';

    angular
        .module('missionhubApp')
        .component('myContactsDashboard', {
            controller: myContactsDashboardController,
            templateUrl: '/templates/myContactsDashboard.html'
        });

    function myContactsDashboardController($http, $log, $q, JsonApiDataStore, envService, _) {
        var vm = this;
        vm.contacts = [];
        vm.organizationPeople = {};
        vm.loading = true;

        vm.getOrgName = getOrgName;

        activate();

        function activate() {
            loadAndSyncData();
        }

        function loadAndSyncData(){
            $q.all([loadMe(), loadPeople()]).then(dataLoaded);
        }

        function loadMe() {
            return $http
                .get(envService.read('apiUrl') + '/people/me', {
                    params: { include: '' }
                })
                .then(function (request) {
                        vm.myPersonId = request.data.data.id;
                    },
                    function(error){
                        $log.error('Error loading profile', error);
                    });
        }

        function loadPeople() {
            return $http
                .get(envService.read('apiUrl') + '/people', {
                    params: {
                        limit: 100,
                        include: 'phone_numbers,reverse_contact_assignments.organization',
                        'filters[assigned_tos]': 'me'
                    }
                })
                .then(function (request) {
                        JsonApiDataStore.store.sync(request.data);
                    },
                    function(error){
                        $log.error('Error loading people', error);
                    });
        }

        function dataLoaded() {
            var people = JsonApiDataStore.store.findAll('person');
            vm.organizationPeople = {};
            angular.forEach(people, function (person) {
                angular.forEach(person.reverse_contact_assignments, function(ca) {
                    if(ca.assigned_to.id != vm.myPersonId) {
                        return;
                    }
                    var orgId = ca.organization.id;
                    if(vm.organizationPeople[orgId] === undefined) {
                        vm.organizationPeople[orgId] = [person];
                    } else {
                        vm.organizationPeople[orgId] = _.union(vm.organizationPeople[orgId],[person]);
                    }
                })
            });

            vm.collapsible = people.length > 5 && _.keys(vm.organizationPeople).length > 2;

            vm.loading = false;
        }

        function getOrgName(orgId) {
            var org = JsonApiDataStore.store.find('organization', orgId);
            if(org) {
                return org.name;
            }
            return orgId;
        }
    }
})();
