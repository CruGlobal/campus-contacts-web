import template from './orgManagement.html';
import './orgManagement.scss';

angular.module('missionhubApp').component('orgManagement', {
    controller: orgManagementController,
    require: {
        organizationOverview: '^',
    },
    template: template,
});

function orgManagementController() {}
