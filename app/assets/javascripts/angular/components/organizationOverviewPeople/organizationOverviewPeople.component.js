import template from './organizationOverviewPeople.html';

angular.module('missionhubApp').component('organizationOverviewPeople', {
    require: {
        organizationOverview: '^',
    },
    template: template,
});
