import './dashboard-subnav.scss';
import template from './dashboard-subnav.html';

angular.module('missionhubApp').component('dashboardSubnav', {
    controller: DashboardSubnavController,
    template: template,
});

function DashboardSubnavController($rootScope, $state) {
    this.$state = $state;
    this.editOrganizations = false;

    this.toggleEditOrganizations = () => {
        this.editOrganizations = !this.editOrganizations;
        $rootScope.$broadcast('editOrganizations', this.editOrganizations);
    };
}
