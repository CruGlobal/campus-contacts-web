import template from './myPeopleDashboard.html';
import './myPeopleDashboard.scss';

angular
    .module('missionhubApp')
    .component('myPeopleDashboard', {
        controller: myPeopleDashboardController,
        bindings: {
            editMode: '<'
        },
        template: template
    });

function myPeopleDashboardController ($scope, $log, $document, JsonApiDataStore, _, I18n,
                                      myPeopleDashboardService, periodService, loggedInPerson,
                                      personService, reportsService, userPreferencesService) {
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
        vm.toggleOrgVisibility = userPreferencesService.toggleOrganizationVisibility;

        vm.sortableOptions = {
            handle: '.sort-orgs-handle',
            stop: function () {
                return userPreferencesService.organizationOrderChange(vm.organizations);
            }
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
        var includes = ['organizational_permissions', 'phone_numbers', 'email_addresses'];
        personService.getContactAssignments(loggedInPerson.person, null, includes).then(dataLoaded);
    }

    function loadReports () {
        var people = JsonApiDataStore.store.findAll('person');
        var organizations = JsonApiDataStore.store.findAll('organization');

        reportsService.loadOrganizationReports(organizations)
            .catch(function (error) {
                $log.error('Error loading organization reports', error);
            });

        reportsService.loadMultiplePeopleReports(organizations, people)
            .catch(function (error) {
                $log.error('Error loading people reports', error);
            });
    }

    function loadOrganizations () {
        myPeopleDashboardService.loadOrganizations({ 'page[limit]': 100 })
            .then(function (organizations) {
                vm.organizations = _.orderBy(organizations, 'active_people_count', 'desc');

                vm.organizations = userPreferencesService.applyUserOrgDisplayPreferences(vm.organizations);

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

        vm.organizations = userPreferencesService.applyUserOrgDisplayPreferences(vm.organizations);

        vm.collapsible = people.length > 10 || _.keys(vm.organizations).length > 1;

        if (_.keys(vm.organizations).length === 0) {
            noPeople();
        }

        vm.loading = false;
    }

    function noPeople () {
        vm.noPeople = true;
        loadOrganizations();
    }
}
