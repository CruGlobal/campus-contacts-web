import './dashboard-subnav.scss';
import template from './dashboard-subnav.html';

angular.module('missionhubApp').component('dashboardSubnav', {
    controller: DashboardSubnavController,
    template: template,
});

function DashboardSubnavController($scope, $state) {
    this.$state = $state;
    this.editOrganizations = false;

    this.toggleEditOrganizations = () => {
        this.editOrganizations = !this.editOrganizations;
        $scope.$emit('editOrganizations', this.editOrganizations);
    };
}
