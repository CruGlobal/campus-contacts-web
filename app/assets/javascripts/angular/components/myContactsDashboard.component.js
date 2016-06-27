(function(){
    'use strict';

    angular
        .module('missionhubApp')
        .component('myContactsDashboard', {
            controller: myContactsDashboardController,
            templateUrl: '/templates/myContactsDashboard.html'
        });

    function myContactsDashboardController($http, $log, $q, $document, JsonApiDataStore, envService, _) {
        var vm = this;
        vm.contacts = [];
        vm.organizationPeople = [];
        vm.loading = true;

        vm.ancestryComparator = ancestryComparator;

        activate();
        vm.$onDestroy = cleanUp;

        function activate() {
            loadAndSyncData();
            angular.element($document).on('contacts::contactAdded', loadAndSyncData);
        }

        function cleanUp() {
            angular.element($document).off('contacts::contactAdded', loadAndSyncData);
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
                        'page[limit]': 100,
                        include: 'phone_numbers,email_addresses,reverse_contact_assignments.organization,' +
                                 'organizational_permissions',
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
            vm.organizationPeople = [];
            angular.forEach(people, function (person) {
                if(person.id == vm.myPersonId) {
                    return;
                }
                angular.forEach(person.reverse_contact_assignments, function(ca) {
                    var orgId = ca.organization.id;
                    // make sure they have an assignment to me and they have an active permission
                    // on the same organization
                    if(ca.assigned_to.id != vm.myPersonId ||
                       _.findIndex(person.organizational_permissions, { organization_id: orgId}) == -1) {
                        return;
                    }
                    var org = _.find(vm.organizationPeople, { id: orgId });
                    if(org === undefined) {
                        org = JsonApiDataStore.store.find('organization', orgId);
                        org.people = [];
                        vm.organizationPeople.push(org)
                    }
                    org.people = _.union(org.people,[person]);
                })
            });

            vm.collapsible = people.length > 5 && _.keys(vm.organizationPeople).length > 2;

            vm.loading = false;
        }

        function ancestryComparator(org1, org2) {
            org1 = JsonApiDataStore.store.find('organization', org1);
            org2 = JsonApiDataStore.store.find('organization', org2);
            if(org1.ancestry != org2.ancestry) {
                return (org2.ancestry < org1.ancestry) ? -1 : 1;
            }
            return (org2.name < org1.name) ? -1 : 1;
        }
    }
})();
