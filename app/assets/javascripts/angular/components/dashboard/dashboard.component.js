import template from './dashboard.html';

angular.module('missionhubApp').component('dashboard', {
    controller: DashboardController,
    template: template,
});

function DashboardController(periodService, $rootScope) {
    const vm = this;
    let deregisterEditOrganizationsEvent;

    vm.editOrganizations = false;
    vm.getPeriod = periodService.getPeriod;
    vm.$onInit = activate;
    vm.$onDestroy = deactivate;

    function activate() {
        deregisterEditOrganizationsEvent = $rootScope.$on(
            'editOrganizations',
            function(event, value) {
                vm.editOrganizations = value;
            },
        );
    }

    function deactivate() {
        deregisterEditOrganizationsEvent();
    }
}
