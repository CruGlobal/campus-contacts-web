(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('peopleFiltersPanel', {
            controller: peopleFiltersPanelController,
            templateUrl: '/assets/angular/components/peopleFiltersPanel/peopleFiltersPanel.html',
            bindings: {
                filtersChanged: '&',
                organizationId: '='
            }
        });

    function peopleFiltersPanelController ($scope, httpProxy, modelsService, _) {
        var vm = this;
        vm.filters = {
            searchString: '',
            labels: {},
            groups: {}
        };
        vm.groupOptions = [];
        vm.labelOptions = [];
        vm.labelFilterCollapsed = true;
        vm.groupFilterCollapsed = true;

        vm.$onInit = activate;

        function activate () {
            $scope.$watch('$ctrl.filters', function (newFilters, oldFilters) {
                if (!_.isEqual(newFilters, oldFilters)) {
                    vm.filtersChanged({ filters: cleanUpFilters() });
                }
            }, true);

            httpProxy.get(modelsService.getModelMetadata('filter_stats').url.single('people'), {
                organization_id: vm.organizationId
            }).then(function (resp) {
                vm.labelOptions = resp.data.labels;
                vm.groupOptions = resp.data.groups;
            });
        }

        function cleanUpFilters () {
            var normalizedFilters = { searchString: vm.filters.searchString };
            normalizedFilters.labels = _.chain(vm.filters.labels)
                                        .pickBy()
                                        .keys()
                                        .value();
            normalizedFilters.groups = _.chain(vm.filters.groups)
                                        .pickBy()
                                        .keys()
                                        .value();
            return normalizedFilters;
        }
    }
})();
