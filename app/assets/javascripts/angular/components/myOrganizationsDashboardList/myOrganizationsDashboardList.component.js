(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('myOrganizationsDashboardList', {
            templateUrl: /* @ngInject */ function (templateUrl) {
                return templateUrl('myOrganizationsDashboardList');
            },
            require: {
                myOrganizationsDashboard: '^'
            },
            bindings: {
                rootOrgs: '<'
            },
            controller: /* @ngInject */ function (userPreferencesService) {
                var vm = this;

                vm.sortableOptions = {
                    handle: '.sort-orgs-handle',
                    stop: function () {
                        return userPreferencesService.organizationOrderChange(vm.rootOrgs);
                    }
                };
            }
        });
})();
