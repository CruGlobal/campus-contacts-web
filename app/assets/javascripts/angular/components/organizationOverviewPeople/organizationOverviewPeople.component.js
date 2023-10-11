import template from './organizationOverviewPeople.html';

angular.module('campusContactsApp').component('organizationOverviewPeople', {
  controller: organizationOverviewPeopleController,
  require: {
    organizationOverview: '^',
  },
  bindings: {
    queryFilters: '<',
  },
  template,
});
function organizationOverviewPeopleController() {}
