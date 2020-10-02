import template from './orgManagement.html';
import './orgManagement.scss';

angular.module('campusContactsApp').component('orgManagement', {
    controller: orgManagementController,
    require: {
        organizationOverview: '^',
    },
    template: template,
});

function orgManagementController() {}
