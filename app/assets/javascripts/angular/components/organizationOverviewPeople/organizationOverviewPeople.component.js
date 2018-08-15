import template from './organizationOverviewPeople.html';

angular.module('missionhubApp').component('organizationOverviewPeople', {
    controller: organizationOverviewPeopleController,
    require: {
        organizationOverview: '^',
    },
    template: template,
});
function organizationOverviewPeopleController(
    organizationOverviewPeopleService,
) {
    this.loaderService = {
        ...organizationOverviewPeopleService,
        listLoader: organizationOverviewPeopleService.createListLoader(),
    };
}
