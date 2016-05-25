(function(){
    'use strict';

    angular
        .module('missionhubApp')
        .component('myContactsDashboard', {
            controller: myContactsDashboardController,
            templateUrl: '/templates/myContactsDashboard.html'
        });

    function myContactsDashboardController($http, $log, $q, JsonApiDataStore, v4ApiURL) {
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
            $q.all([loadPeople(), loadOrganizations()]).then(dataLoaded);
        }

        function loadPeople() {
            return $http
                .get(v4ApiURL + '/people', {
                    params: {
                        limit: 50,
                        include: 'person.id,person.email_addresses,' +
                                 'person.organizational_permissions,person.phone_numbers'
                    }
                })
                .then(function (request) {
                        JsonApiDataStore.store.sync(request.data);
                    },
                    function(error){
                        $log.error('Error loading people', error);
                    });
        }

        function loadOrganizations() {
            return $http
                .get(v4ApiURL + '/organizations', {
                    params: {
                        limit: 100,
                        include : 'organization.name,organization.id'
                    }
                })
                .then(function(request) {
                        JsonApiDataStore.store.sync(request.data);
                    },
                    function(error){
                        $log.error('Error loading orgs', error);
                    });
        }

        function dataLoaded() {
            var people = JsonApiDataStore.store.findAll('person');
            vm.organizationPeople = {};
            angular.forEach(people, function (person) {
                angular.forEach(person.organizational_permissions, function(op) {
                    var orgId = op.organization_id;
                    if(vm.organizationPeople[orgId] === undefined) {
                        vm.organizationPeople[orgId] = [person];
                    } else {
                        vm.organizationPeople[orgId].push(person);
                    }
                })
            });
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
