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

    function myContactsDashboardController ($http, $log, $q, $document, JsonApiDataStore, envService, _, I18n) {
        var vm = this;
        vm.contacts = [];
        vm.organizationPeople = [];
        vm.loading = true;
        vm.noContacts = false;
        vm.numberOfOrgsToShow = 1000;
        vm.noPeopleShowLimit = 4;

        activate();
        vm.$onDestroy = cleanUp;
        vm.$onChanges = bindingsChanged;

        vm.orgChangeVisibility = orgChangeVisibility;

        vm.noContactsWelcome = '';

        function activate () {
            loadAndSyncData();
            angular.element($document).on('contacts::contactAdded', loadAndSyncData);

            vm.sortableOptions = {
                handle: '.sort-orgs-handle',
                stop: organizationOrderChange
            }
        }

        function cleanUp () {
            angular.element($document).off('contacts::contactAdded', loadAndSyncData);
        }

        function loadAndSyncData () {
            $q.all([loadMe(), loadPeople()]).then(dataLoaded);
        }

        function bindingsChanged (changesObj) {
            if(changesObj.period && !vm.loading) {
                loadReports();
            }
        }

        function loadMe () {
            return $http
                .get(envService.read('apiUrl') + '/people/me', {
                    params: { include: 'user' }
                })
                .then(function (request) {
                        vm.myPersonId = request.data.data.id;
                        vm.noContactsWelcome = I18n.t('dashboard.no_contacts.welcome', {
                            name: request.data.data.attributes.first_name.toUpperCase()
                        });
                        vm.orgOrderPreference = request.data.included[0].attributes.organization_order;
                        vm.orgHiddenPreference = request.data.included[0].attributes.hidden_organizations || [];
                    },
                    function (error) {
                        $log.error('Error loading profile', error);
                    });
        }

        function loadPeople () {
            return $http
                .get(envService.read('apiUrl') + '/people', {
                    params: {
                        'page[limit]': 250,
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

        function loadReports () {
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

        function loadOrganizations () {
            return $http
                .get(envService.read('apiUrl') + '/organizations', {
                    params: {
                        'page[limit]': 100,
                        order: 'active_people_count',
                        include: ''
                    }
                })
                .then(function (request) {
                        JsonApiDataStore.store.sync(request.data);
                    },
                    function (error) {
                        $log.error('Error loading organizations', error);
                    });
        }

        function dataLoaded () {
            loadReports();
            var people = JsonApiDataStore.store.findAll('person');
            vm.organizationPeople = [];
            angular.forEach(people, function (person) {
                if (person.id == vm.myPersonId) {
                    return;
                }
                if (angular.isUndefined(person.last_name) || person.last_name === null) {
                    person.last_name = '';
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
                    if (angular.isUndefined(org)) {
                        org = JsonApiDataStore.store.find('organization', orgId);
                        org.people = [];
                        vm.organizationPeople.push(org)
                    }
                    org.people = _.union(org.people, [person]);
                })
            });
            orderOrganizations();
            hideOrganizations();

            vm.collapsible = people.length > 10 || _.keys(vm.organizationPeople).length > 1;

            if(_.keys(vm.organizationPeople).length == 0) {
                noContacts();
            }

            vm.loading = false;
        }

        function orderOrganizations () {
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
            _.each(oldArray, function (org) {
                newArray.push(org);
            });
            vm.organizationPeople = newArray;
        }

        function hideOrganizations () {
            _.each(vm.organizationPeople, function (org) {
                var hidden = vm.orgHiddenPreference.indexOf(org.id.toString());
                org.visible = hidden == -1;
            })
        }

        function noContacts () {
            vm.noContacts = true;
            loadOrganizations().then(function () {
                vm.organizationPeople = _.orderBy(JsonApiDataStore.store.findAll('organization'),
                                                  'active_people_count',
                                                  'desc');
                orderOrganizations();
                hideOrganizations();
                if (vm.organizationPeople.length <= vm.noPeopleShowLimit) {
                    vm.numberOfOrgsToShow = 100;
                }
                else {
                    vm.numberOfOrgsToShow = vm.noPeopleShowLimit;
                }
                loadReports();
            })
        }

        function organizationOrderChange () {
            var orgOrder = _.map(vm.organizationPeople, 'id');
            updateUserPreference({
                organization_order: orgOrder
            })
        }

        function orgChangeVisibility (organization_id) {
            var org = _.find(vm.organizationPeople, {id: organization_id});
            var hidding = org.visible;
            org.visible = !org.visible;
            if (hidding) {
                vm.orgHiddenPreference.push(organization_id);
            }
            else {
                vm.orgHiddenPreference = _.remove(vm.orgHiddenPreference, organization_id);
            }
            updateUserPreference({
                hidden_organizations: vm.orgHiddenPreference
            });
        }

        function updateUserPreference (prefHash) {
            var userData = {
                data: {
                    type: 'user',
                    attributes: prefHash
                }
            };
            $http.put(envService.read('apiUrl') + '/users/me', userData)
        }
    }
})();
