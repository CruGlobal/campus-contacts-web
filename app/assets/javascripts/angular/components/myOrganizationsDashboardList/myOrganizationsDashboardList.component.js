import template from './myOrganizationsDashboardList.html';

angular.module('missionhubApp').component('myOrganizationsDashboardList', {
    template: template,
    bindings: {
        rootOrgs: '<',
    },
    controller: /* @ngInject */ function(userPreferencesService, $scope) {
        let deregisterEditOrganizationsEvent;

        deregisterEditOrganizationsEvent = $scope.$on(
            'editOrganizations',
            (event, value) => {
                this.editOrganizations = value;
            },
        );

        var vm = this;

        this.$onDestroy = () => {
            deregisterEditOrganizationsEvent();
        };

        vm.sortableOptions = {
            handle: '.sort-orgs-handle',
            stop: function() {
                return userPreferencesService.organizationOrderChange(
                    vm.rootOrgs,
                );
            },
        };
    },
});
