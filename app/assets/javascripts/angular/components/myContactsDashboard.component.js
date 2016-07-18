(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('myContactsDashboard', {
            controller: myContactsDashboardController,
            bindings: {
                period: '<',
                'editMode': '<'
            },
            templateUrl: '/templates/myContactsDashboard.html'
        });

    function myContactsDashboardController($http, $log, $q, $document, JsonApiDataStore, envService, _) {
        var vm = this;
        vm.contacts = [];
        vm.organizationPeople = [];
        vm.loading = true;

        activate();
        vm.$onDestroy = cleanUp;
        vm.$onChanges = bindingsChanged;

        function activate() {
            loadAndSyncData();
            angular.element($document).on('contacts::contactAdded', loadAndSyncData);

            vm.sortableOptions = {
                handle: '.sort-orgs-handle',
                stop: organizationOrderChange
            }
        }

        function cleanUp() {
            angular.element($document).off('contacts::contactAdded', loadAndSyncData);
        }

        function loadAndSyncData() {
            $q.all([loadMe(), loadPeople()]).then(dataLoaded);
        }

        function bindingsChanged(changesObj) {
            if(changesObj.period && !vm.loading) {
                loadReports();
            }
        }

        function loadMe() {
            return $http
                .get(envService.read('apiUrl') + '/people/me', {
                    params: { include: 'user' }
                })
                .then(function (request) {
                        vm.myPersonId = request.data.data.id;
                        vm.orgOrderPreference = request.data.included[0].attributes.organization_order;
                    },
                    function (error) {
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
                    function (error) {
                        $log.error('Error loading people', error);
                    });
        }

        function loadReports() {
            var people_ids = _.map(JsonApiDataStore.store.findAll('person'), 'id').join(','),
                organization_ids = _.map(JsonApiDataStore.store.findAll('organization'), 'id').join(',');

            $http.get(envService.read('apiUrl') + '/reports/organizations', {
                params: {
                    period: vm.period,
                    organization_ids: organization_ids
                }
            }).then(function (request) {
                JsonApiDataStore.store.sync(request.data);
            }, function (error) {
                $log.error('Error loading organization reports', error);
            });

            $http.get(envService.read('apiUrl') + '/reports/people', {
                params: {
                    period: vm.period,
                    organization_ids: organization_ids,
                    people_ids: people_ids
                }
            }).then(function (request) {
                JsonApiDataStore.store.sync(request.data);
            }, function (error) {
                $log.error('Error loading people reports', error);
            });
        }

        function dataLoaded() {
            loadReports();
            var people = JsonApiDataStore.store.findAll('person');
            vm.organizationPeople = [];
            angular.forEach(people, function (person) {
                if (person.id == vm.myPersonId) {
                    return;
                }
                angular.forEach(person.reverse_contact_assignments, function (ca) {
                    var orgId = ca.organization.id;
                    // make sure they have an assignment to me and they have an active permission
                    // on the same organization
                    if (ca.assigned_to.id != vm.myPersonId ||
                        _.findIndex(person.organizational_permissions, {organization_id: orgId}) == -1) {
                        return;
                    }
                    var org = _.find(vm.organizationPeople, {id: orgId});
                    if (org === undefined) {
                        org = JsonApiDataStore.store.find('organization', orgId);
                        org.people = [];
                        vm.organizationPeople.push(org)
                    }
                    org.people = _.union(org.people, [person]);
                })
            });
            orderOrganizations();

            vm.collapsible = people.length > 5 && _.keys(vm.organizationPeople).length > 2;

            vm.loading = false;
        }

        function orderOrganizations() {
            if(!vm.orgOrderPreference) {
                vm.organizationPeople = _.orderBy(vm.organizationPeople, ['ancestry', 'name']);
                return;
            }
            var oldArray = _.clone(vm.organizationPeople);
            var newArray = [];
            _.each(vm.orgOrderPreference, function (org) {
                var found = _.remove(oldArray, {id: org})[0];
                if(found) {
                    newArray.push(found);
                }
            });
            oldArray = _.orderBy(oldArray, ['ancestry', 'name']);
            _.each(oldArray, function(org) {
                newArray.push(org);
            });
            vm.organizationPeople = newArray;
        }

        function organizationOrderChange() {
            var orgOrder = _.map(vm.organizationPeople, 'id');
            var userData = {
                data: {
                    type: 'user',
                    attributes: {
                        organization_order: orgOrder
                    }
                }
            };
            $http.put(envService.read('apiUrl') + '/users/me', userData)
        }
    }
})();
