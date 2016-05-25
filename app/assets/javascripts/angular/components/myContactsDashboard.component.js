(function(){
    'use strict';

    angular
        .module('missionhubApp')
        .component('myContactsDashboard', {
            controller: myContactsDashboardController,
            templateUrl: '/templates/myContactsDashboard.html'
        });

    function myContactsDashboardController($http, JsonApiDataStore, Rx, $log) {
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
            Rx.Observable.merge(loadPeople(), loadOrganizations())
                .subscribe(
                    function(payload){
                        JsonApiDataStore.store.sync(payload.data);
                    },
                    function(error){
                        $log.error('Error loading people and orgs', error);
                    },
                    dataLoaded
                );
        }

        function loadPeople() {
            return Rx.Observable.from($http.get('http://localhost:3001/apis/v4/people', {
                params: {
                    limit: 50,
                    include: 'person.id,person.first_name,person.last_name,person.email_addresses,person.phone_numbers,' +
                    'person.organizational_permissions,email_addresses.id,email_addresses.email,' +
                    'organizationalPermissions.organization_id'
                }
            }));
        }

        function loadOrganizations() {
            return Rx.Observable.from($http.get('http://localhost:3001/apis/v4/organizations', {
                params: {
                    limit: 100,
                    include : 'organization.name,organization.id'
                }
            }));
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
