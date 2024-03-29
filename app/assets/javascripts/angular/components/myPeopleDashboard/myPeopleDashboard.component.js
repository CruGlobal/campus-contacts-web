import i18next from 'i18next';
import moment from 'moment';

import favicon from '../../../../images/favicon.svg';
import iosShare from '../../../../images/icons/ios-share.svg';

import template from './myPeopleDashboard.html';
import './myPeopleDashboard.scss';

angular.module('campusContactsApp').component('myPeopleDashboard', {
  controller: myPeopleDashboardController,
  bindings: {
    editMode: '<',
  },
  template,
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
  const vm = this;
  vm.people = [];
  vm.organizations = [];
  vm.loading = true;
  vm.noPeople = false;

  vm.favicon = favicon;
  vm.iosShare = iosShare;

  vm.sortableOptions = {
    handle: '.sort-orgs-handle',
    ghostClass: 'o-40',
    forceFallback: true, // Needed to make sticky header and scrollSensitivity work
    scrollSensitivity: 100,
    onEnd: () => userPreferencesService.organizationOrderChange(vm.organizations),
  };

  vm.$onInit = async () => {
    await loggedInPerson.loadOnce();
    await loadAndSyncData();

    angular.element($document).on('people::personAdded', loadAndSyncData);
    vm.toggleOrgVisibility = userPreferencesService.toggleOrganizationVisibility;

    vm.noPeopleWelcome = i18next.t('dashboard.no_contacts.welcome', {
      name: loggedInPerson.person.first_name.toUpperCase(),
    });

    periodService.subscribe($scope, loadReports);

    $scope.$apply();
  };

  vm.$onDestroy = cleanUp;

  vm.noPeopleWelcome = '';

  vm.showSuggestLandscape = () =>
    // Yes this code can be removed after this date https://jira.cru.org/browse/MHP-3002?focusedCommentId=84408&page=com.atlassian.jira.plugin.system.issuetabpanels:comment-tabpanel#comment-84408
    moment().isBefore('2020-12-01') &&
    myPeopleDashboardService.isMobile() &&
    $window.matchMedia('(orientation: portrait)').matches &&
    !localStorage.getItem('hideSuggestLandscape');

  vm.dismissSuggestLandscape = () => localStorage.setItem('hideSuggestLandscape', true);

  vm.showIosAddToHomeScreen = () =>
    myPeopleDashboardService.isIos() && !window.navigator.standalone && !localStorage.getItem('hideIosAddToHomeScreen');

  vm.dismissIosAddToHomeScreen = () => localStorage.setItem('hideIosAddToHomeScreen', true);

  function cleanUp() {
    angular.element($document).off('people::personAdded', loadAndSyncData);
  }

  function loadAndSyncData() {
    const includes = ['organizational_permissions', 'phone_numbers', 'email_addresses'];

    personService.getContactAssignments(loggedInPerson.person, null, includes).then(dataLoaded);
  }

  function loadReports() {
    const people = vm.organizations.flatMap(({ people }) => people);
    const organizations = vm.organizations;

    const limitLength = 100;
    const warnLength = 25;

    if (people.length > limitLength || organizations.length > limitLength) {
      $log.error(`People dashboard tried to load more than ${limitLength} reports. Report ids truncated.`, {
        numPeopleIds: people.length,
        numCommunityIds: organizations.length,
      });
    } else if (people.length > warnLength || organizations.length > warnLength) {
      $log.warn(`People dashboard loaded more than ${warnLength} reports.`, {
        numPeopleIds: people.length,
        numCommunityIds: organizations.length,
      });
    }

    const limitedOrganizations = organizations.slice(0, limitLength);
    const limitedPeople = people.slice(0, limitLength);

    reportsService.loadOrganizationReports(limitedOrganizations).catch(function (error) {
      $log.error('Error loading organization reports', error);
    });

    reportsService.loadMultiplePeopleReports(limitedOrganizations, limitedPeople).catch(function (error) {
      $log.error('Error loading people reports', error);
    });
  }

  function loadOrganizations() {
    myPeopleDashboardService
      .loadOrganizations({ 'page[limit]': 100 })
      .then(function (organizations) {
        vm.organizations = organizations;

        vm.organizations = userPreferencesService.applyUserOrgDisplayPreferences(vm.organizations);
        loadReports();
      })
      .catch(function (error) {
        $log.error('Error loading organizations', error);
      });
  }

  function dataLoaded(assignmentsToMe) {
    const people = JsonApiDataStore.store.findAll('person');
    people.forEach(function (person) {
      if (_.isNil(person.last_name)) {
        person.last_name = '';
      }
    });

    // Get the array of all the organizations that have at least one person assigned to me
    vm.organizations = _.chain(assignmentsToMe).map('organization').uniq().value();

    vm.organizations.forEach(function (organization) {
      // Get an array of the people assigned to me on this organization
      organization.people = _.filter(assignmentsToMe, {
        organization,
      }).map(function (assignment) {
        return JsonApiDataStore.store.find('person', assignment.person_id);
      });
    });

    vm.organizations = userPreferencesService.applyUserOrgDisplayPreferences(vm.organizations);

    vm.collapsible = people.length > 10 || _.keys(vm.organizations).length > 1;

    if (_.keys(vm.organizations).length === 0) {
      noPeople();
    }
    loadReports();
    vm.loading = false;
  }

  function noPeople() {
    vm.noPeople = true;
    loadOrganizations();
  }
}
