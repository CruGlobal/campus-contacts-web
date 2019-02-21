import template from './organizationOverviewPeople.html';

angular.module('missionhubApp').component('organizationOverviewPeople', {
    controller: organizationOverviewPeopleController,
    require: {
        organizationOverview: '^',
    },
    bindings: {
        queryFilters: '<',
    },
    template: template,
});
function organizationOverviewPeopleController() {}
