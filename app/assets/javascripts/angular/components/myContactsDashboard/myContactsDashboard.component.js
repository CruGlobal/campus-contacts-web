(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('myContactsDashboard', {
            controller: myContactsDashboardController,
            bindings: {
                'editMode': '<'
            },
            templateUrl: '/assets/angular/components/myContactsDashboard/myContactsDashboard.html'
        });

    function myContactsDashboardController ($scope, $log, $document, JsonApiDataStore, _, I18n,
                                            myContactsDashboardService, periodService, loggedInPerson,
                                            reportsService) {
        var vm = this;
        vm.contacts = [];
        vm.organizationPeople = [];
        vm.loading = true;
        vm.noContacts = false;
        vm.numberOfOrgsToShow = 1000;
        vm.noPeopleShowLimit = 4;

        activate();
        vm.$onDestroy = cleanUp;

        vm.toggleOrgVisibility = myContactsDashboardService.toggleOrganizationVisibility;

        vm.noContactsWelcome = '';

        function activate () {
            loadAndSyncData();
            angular.element($document).on('contacts::contactAdded', loadAndSyncData);

            vm.sortableOptions = {
                handle: '.sort-orgs-handle',
                stop: organizationOrderChange
            }

            vm.noContactsWelcome = I18n.t('dashboard.no_contacts.welcome', {
                name: loggedInPerson.person.first_name.toUpperCase()
            });

            loadReports();
            periodService.subscribe($scope, loadReports);
        }

        function cleanUp () {
            angular.element($document).off('contacts::contactAdded', loadAndSyncData);
        }

        function loadAndSyncData () {
            loadPeople().then(dataLoaded);
        }

        function loadPeople () {
            var promise = myContactsDashboardService.loadPeople({
                'page[limit]': 250,
                include: 'phone_numbers,email_addresses,reverse_contact_assignments.organization,' +
                'organizational_permissions',
                'filters[assigned_tos]': 'me'
            });
            return promise.catch(function (error) {
                $log.error('Error loading people', error);
            });
        }

        function loadReports () {
            var people_ids = _.map(JsonApiDataStore.store.findAll('person'), 'id').join(','),
                organization_ids = _.map(JsonApiDataStore.store.findAll('organization'), 'id');

            var peopleReportParams = {
                organization_ids: organization_ids,
                people_ids: people_ids
            };

            var organizationReportPromise = reportsService.loadOrganizationReports(organization_ids);
            organizationReportPromise.catch(function (error) {
                $log.error('Error loading organization reports', error);
            });

            var peopleReportPromise = myContactsDashboardService.loadPeopleReports(peopleReportParams);
            peopleReportPromise.catch(function (error) {
                $log.error('Error loading people reports', error);
            });
        }

        function loadOrganizations () {
            var promise = myContactsDashboardService.loadOrganizations({ 'page[limit]': 100 });
            promise.then(function () {
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
                if (person.id === loggedInPerson.person.id) {
                    return;
                }
                if (angular.isUndefined(person.last_name) || person.last_name === null) {
                    person.last_name = '';
                }
                angular.forEach(person.reverse_contact_assignments, function (ca) {
                    if (!ca.organization) {
                        // Make sure that the organization relation is loaded
                        return;
                    }

                    var orgId = ca.organization.id;
                    // make sure they have an assignment to me and they have an active permission
                    // on the same organization
                    if (ca.assigned_to.id !== loggedInPerson.person.id ||
                        _.findIndex(person.organizational_permissions, { organization_id: orgId }) === -1) {
                        return;
                    }
                    var org = _.find(vm.organizationPeople, { id: orgId });
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

            if(_.keys(vm.organizationPeople).length === 0) {
                noContacts();
            }

            vm.loading = false;
        }

        function orderOrganizations () {
            var orgOrderPreference = loggedInPerson.person.user.organization_order;
            if(!orgOrderPreference) {
                vm.organizationPeople = _.orderBy(vm.organizationPeople, ['ancestry', 'name']);
                return;
            }
            var oldArray = _.clone(vm.organizationPeople);
            var newArray = [];
            _.each(orgOrderPreference, function (org) {
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
            var orgHiddenPreference = loggedInPerson.person.user.hidden_organizations || [];
            _.each(vm.organizationPeople, function (org) {
                var hidden = orgHiddenPreference.indexOf(org.id.toString());
                org.visible = hidden === -1;
            })
        }

        function noContacts () {
            vm.noContacts = true;
            loadOrganizations();
        }

        function organizationOrderChange () {
            var orgOrder = _.map(vm.organizationPeople, 'id');
            myContactsDashboardService.updateUserPreference({
                organization_order: orgOrder
            });
        }
    }
})();
