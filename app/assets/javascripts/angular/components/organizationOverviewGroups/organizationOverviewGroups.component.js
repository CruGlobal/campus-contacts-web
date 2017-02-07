(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('organizationOverviewGroups', {
            controller: organizationOverviewGroupsController,
            require: {
                organizationOverview: '^organizationOverview'
            },
            bindings: {
                org: '<'
            },
            templateUrl: '/assets/angular/components/organizationOverviewGroups/organizationOverviewGroups.html'
        });

    function organizationOverviewGroupsController ($uibModal) {
        var vm = this;
        vm.addGroup = addGroup;

        function addGroup () {
            $uibModal.open({
                animation: true,
                component: 'editGroup',
                resolve: {
                    organizationId: function () {
                        return vm.organizationOverview.org.id;
                    }
                },
                windowClass: 'pivot_theme',
                size: 'sm'
            });

            return false;
        }
    }
})();
