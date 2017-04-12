(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('myPeopleDashboard', {
            controller: myPeopleDashboardController,
            bindings: {
                editMode: '<'
            },
            templateUrl: /* @ngInject */ function (templateUrl) {
                return templateUrl('myPeopleDashboard');
            }
        });

    function myPeopleDashboardController ($scope, $log, $document, JsonApiDataStore, _, I18n,
                                          myPeopleDashboardService, periodService, loggedInPerson,
                                          personService, reportsService) {
        var vm = this;
        vm.people = [];
        vm.organizations = [];
        vm.loading = true;
        vm.noPeople = false;
        vm.numberOfOrgsToShow = 1000;
        vm.noPeopleShowLimit = 4;

        vm.$onInit = activate;

        vm.$onDestroy = cleanUp;

        vm.noPeopleWelcome = '';

        function activate () {
            loadAndSyncData();
            angular.element($document).on('people::personAdded', loadAndSyncData);
            vm.toggleOrgVisibility = myPeopleDashboardService.toggleOrganizationVisibility;

            vm.sortableOptions = {
                handle: '.sort-orgs-handle',
                stop: organizationOrderChange
            };

            vm.noPeopleWelcome = I18n.t('dashboard.no_contacts.welcome', {
                name: loggedInPerson.person.first_name.toUpperCase()
            });

            periodService.subscribe($scope, loadReports);
        }

        function cleanUp () {
            angular.element($document).off('people::personAdded', loadAndSyncData);
        }

        function loadAndSyncData () {
            personService.getContactAssignments(loggedInPerson.person, null).then(dataLoaded);
        }

        function loadReports () {
            var peopleIds = _.map(JsonApiDataStore.store.findAll('person'), 'id');
            var organizationIds = _.map(JsonApiDataStore.store.findAll('organization'), 'id');

            var peopleReportParams = {
                organization_ids: organizationIds,
                people_ids: peopleIds
            };

            var organizationReportPromise = reportsService.loadOrganizationReports(organizationIds);
            organizationReportPromise.catch(function (error) {
                $log.error('Error loading organization reports', error);
            });

            var peopleReportPromise = myPeopleDashboardService.loadPeopleReports(peopleReportParams);
            peopleReportPromise.catch(function (error) {
                $log.error('Error loading people reports', error);
            });
        }

        function loadOrganizations () {
            myPeopleDashboardService.loadOrganizations({ 'page[limit]': 100 })
                .then(function (organizations) {
                    vm.organizations = _.orderBy(organizations, 'active_people_count', 'desc');

                    orderOrganizations();
                    hideOrganizations();

                    if (vm.organizations.length <= vm.noPeopleShowLimit) {
                        vm.numberOfOrgsToShow = 100;
                    } else {
                        vm.numberOfOrgsToShow = vm.noPeopleShowLimit;
                    }
                    loadReports();
                })
                .catch(function (error) {
                    $log.error('Error loading organizations', error);
                });
        }

        function dataLoaded (assignmentsToMe) {
            loadReports();
            var people = JsonApiDataStore.store.findAll('person');
            people.forEach(function (person) {
                if (_.isNil(person.last_name)) {
                    person.last_name = '';
                }
            });

            // Get the array of all the organizations that have at least one person assigned to me
            vm.organizations = _.chain(assignmentsToMe)
                .map('organization')
                .uniq()
                .value();

            vm.organizations.forEach(function (organization) {
                // Get an array of the people assigned to me on this organization
                organization.people = _.filter(assignmentsToMe, { organization: organization })
                    .map(function (assignment) {
                        return JsonApiDataStore.store.find('person', assignment.person_id);
                    });
            });

            orderOrganizations();
            hideOrganizations();

            vm.collapsible = people.length > 10 || _.keys(vm.organizations).length > 1;

            if (_.keys(vm.organizations).length === 0) {
                noPeople();
            }

            vm.loading = false;
        }

        function orderOrganizations () {
            var orgOrderPreference = loggedInPerson.person.user.organization_order;
            if (!orgOrderPreference) {
                vm.organizations = _.orderBy(vm.organizations, ['ancestry', 'name']);
                return;
            }
            var oldArray = _.clone(vm.organizations);
            var newArray = [];
            _.each(orgOrderPreference, function (org) {
                var found = _.remove(oldArray, { id: org })[0];
                if (found) {
                    newArray.push(found);
                }
            });
            oldArray = _.orderBy(oldArray, ['ancestry', 'name']);
            _.each(oldArray, function (org) {
                newArray.push(org);
            });
            vm.organizations = newArray;
        }

        function hideOrganizations () {
            var orgHiddenPreference = loggedInPerson.person.user.hidden_organizations || [];
            _.each(vm.organizations, function (org) {
                var hidden = orgHiddenPreference.indexOf(org.id.toString());
                org.visible = hidden === -1;
            });
        }

        function noPeople () {
            vm.noPeople = true;
            loadOrganizations();
        }

        function organizationOrderChange () {
            var orgOrder = _.map(vm.organizations, 'id');
            myPeopleDashboardService.updateUserPreference({
                organization_order: orgOrder
            }, 'error.messages.my_people_dashboard.update_org_order');
        }
    }
})();
