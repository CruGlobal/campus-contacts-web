import i18next from 'i18next';

import template from './myPeopleDashboard.html';
import './myPeopleDashboard.scss';

angular.module('missionhubApp').component('myPeopleDashboard', {
    controller: myPeopleDashboardController,
    bindings: {
        editMode: '<',
    },
    template: template,
});

function myPeopleDashboardController(
    $scope,
    $log,
    $document,
    $window,
    JsonApiDataStore,
    _,
    myPeopleDashboardService,
    periodService,
    loggedInPerson,
    personService,
    reportsService,
    userPreferencesService,
) {
    var vm = this;
    vm.people = [];
    vm.organizations = [];
    vm.loading = true;
    vm.noPeople = false;

    vm.sortableOptions = {
        handle: '.sort-orgs-handle',
        ghostClass: 'o-40',
        forceFallback: true, // Needed to make sticky header and scrollSensitivity work
        scrollSensitivity: 100,
        onEnd: () =>
            userPreferencesService.organizationOrderChange(vm.organizations),
    };

    vm.$onInit = async () => {
        await loggedInPerson.loadOnce();
        await loadAndSyncData();

        if (
            // If the logged in person has no organization permissions, redirect the user to download mobile app
            loggedInPerson.person.organizational_permissions.length === 0
        ) {
            $window.location.href = 'https://get.missionhub.com/newmobileuser/';
        }

        angular.element($document).on('people::personAdded', loadAndSyncData);
        vm.toggleOrgVisibility =
            userPreferencesService.toggleOrganizationVisibility;

        vm.noPeopleWelcome = i18next.t('dashboard.no_contacts.welcome', {
            name: loggedInPerson.person.first_name.toUpperCase(),
        });

        periodService.subscribe($scope, loadReports);

        $scope.$apply();
    };

    vm.$onDestroy = cleanUp;

    vm.noPeopleWelcome = '';

    function cleanUp() {
        angular.element($document).off('people::personAdded', loadAndSyncData);
    }

    function loadAndSyncData() {
        var includes = [
            'organizational_permissions',
            'phone_numbers',
            'email_addresses',
        ];

        personService
            .getContactAssignments(loggedInPerson.person, null, includes)
            .then(dataLoaded);
    }

    function loadReports() {
        var people = JsonApiDataStore.store.findAll('person');
        var organizations = vm.organizations;

        reportsService
            .loadOrganizationReports(organizations)
            .catch(function(error) {
                $log.error('Error loading organization reports', error);
            });

        reportsService
            .loadMultiplePeopleReports(organizations, people)
            .catch(function(error) {
                $log.error('Error loading people reports', error);
            });
    }

    function loadOrganizations() {
        myPeopleDashboardService
            .loadOrganizations({ 'page[limit]': 100 })
            .then(function(organizations) {
                vm.organizations = organizations;

                vm.organizations = userPreferencesService.applyUserOrgDisplayPreferences(
                    vm.organizations,
                );
                loadReports();
            })
            .catch(function(error) {
                $log.error('Error loading organizations', error);
            });
    }

    function dataLoaded(assignmentsToMe) {
        loadReports();
        var people = JsonApiDataStore.store.findAll('person');
        people.forEach(function(person) {
            if (_.isNil(person.last_name)) {
                person.last_name = '';
            }
        });

        // Get the array of all the organizations that have at least one person assigned to me
        vm.organizations = _.chain(assignmentsToMe)
            .map('organization')
            .uniq()
            .value();

        vm.organizations.forEach(function(organization) {
            // Get an array of the people assigned to me on this organization
            organization.people = _.filter(assignmentsToMe, {
                organization: organization,
            }).map(function(assignment) {
                return JsonApiDataStore.store.find(
                    'person',
                    assignment.person_id,
                );
            });
        });

        vm.organizations = userPreferencesService.applyUserOrgDisplayPreferences(
            vm.organizations,
        );

        vm.collapsible =
            people.length > 10 || _.keys(vm.organizations).length > 1;

        if (_.keys(vm.organizations).length === 0) {
            noPeople();
        }

        vm.loading = false;
    }

    function noPeople() {
        vm.noPeople = true;
        loadOrganizations();
    }
}
