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
        vm.organizationContacts = {};
        vm.loading = true;

        vm.orgName = orgName;

        activate();

        function activate() {
            loadAndSyncData();
        }

        function loadAndSyncData(){
            Rx.Observable.merge(loadContacts(), loadOrganizations())
                .subscribe(
                    function(payload){
                        JsonApiDataStore.store.sync(payload.data);
                    },
                    function(error){
                        $log.error('Error loading contacts and orgs', error);
                    },
                    dataLoaded
                );
        }

        function loadContacts() {
            return Rx.Observable.from($http.get('http://localhost:3001/apis/v4/people', {
                params: {
                    limit: 50,
                    include: 'person.id,person.first_name,person.last_name,person.email_addresses,' +
                    'person.organizational_permissions,emailAddresses.id,emailAddresses.email,' +
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
            vm.contacts = JsonApiDataStore.store.findAll('person');
            vm.organizationContacts = {};
            angular.forEach(vm.contacts, function (contact) {
                angular.forEach(contact.organizational_permissions, function(op) {
                    var orgId = op.organization_id;
                    if(vm.organizationContacts[orgId] === undefined) {
                        vm.organizationContacts[orgId] = [contact];
                    } else {
                        vm.organizationContacts[orgId].push(contact);
                    }
                })
            });
            vm.loading = false;
        }

        function orgName(orgId) {
            var org = JsonApiDataStore.store.find('organization', orgId);
            if(org) {
                return org.name;
            }
            return orgId;
        }
    }
})();
