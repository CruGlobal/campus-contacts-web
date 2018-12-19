import template from './organizationCleanup.html';
import './organizationCleanup.scss';

angular.module('missionhubApp').component('organizationCleanup', {
    bindings: {
        orgId: '<',
    },
    template: template,
    controller: organizationCleanupController,
});

function organizationCleanupController() {
    this.archiveDate = new Date();
    this.dateOptions = {
        formatYear: 'yy',
        maxDate: new Date(2020, 5, 22),
        minDate: new Date(),
        startingDay: 1,
    };
}
