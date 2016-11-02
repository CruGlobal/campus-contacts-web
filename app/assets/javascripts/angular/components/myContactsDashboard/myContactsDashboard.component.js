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
                                            personService, reportsService) {
        var vm = this;
        vm.contacts = [];
        vm.organizations = [];
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

            periodService.subscribe($scope, loadReports);
        }

        function cleanUp () {
            angular.element($document).off('contacts::contactAdded', loadAndSyncData);
        }

        function loadAndSyncData () {
            personService.getContactAssignments(loggedInPerson.person, null).then(dataLoaded);
        }

        function loadReports () {
            var people_ids = _.map(JsonApiDataStore.store.findAll('person'), 'id'),
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
            myContactsDashboardService.loadOrganizations({ 'page[limit]': 100 }).then(function (organizations) {
                vm.organizations = _.orderBy(organizations, 'active_people_count', 'desc');

                orderOrganizations();
                hideOrganizations();

                if (vm.organizations.length <= vm.noPeopleShowLimit) {
                    vm.numberOfOrgsToShow = 100;
                }
                else {
                    vm.numberOfOrgsToShow = vm.noPeopleShowLimit;
                }
                loadReports();
            }).catch(function (error) {
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
            vm.organizations = _.chain(assignmentsToMe).map('organization').uniq().value();

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

            if(_.keys(vm.organizations).length === 0) {
                noContacts();
            }

            vm.loading = false;
        }

        function orderOrganizations () {
            var orgOrderPreference = loggedInPerson.person.user.organization_order;
            if(!orgOrderPreference) {
                vm.organizations = _.orderBy(vm.organizations, ['ancestry', 'name']);
                return;
            }
            var oldArray = _.clone(vm.organizations);
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
            vm.organizations = newArray;
        }

        function hideOrganizations () {
            var orgHiddenPreference = loggedInPerson.person.user.hidden_organizations || [];
            _.each(vm.organizations, function (org) {
                var hidden = orgHiddenPreference.indexOf(org.id.toString());
                org.visible = hidden === -1;
            })
        }

        function noContacts () {
            vm.noContacts = true;
            loadOrganizations();
        }

        function organizationOrderChange () {
            var orgOrder = _.map(vm.organizations, 'id');
            myContactsDashboardService.updateUserPreference({
                organization_order: orgOrder
            });
        }
    }
})();
