import template from './myOrganizationsDashboardList.html';

angular.module('missionhubApp').component('myOrganizationsDashboardList', {
    template: template,
    require: {
        myOrganizationsDashboard: '^',
    },
    bindings: {
        rootOrgs: '<',
    },
    controller: /* @ngInject */ function(userPreferencesService, $scope) {
        let deregisterEditOrganizationsEvent;

        deregisterEditOrganizationsEvent = $scope.$on(
            'editOrganizations',
            (event, value) => {
                console.log(value);
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
