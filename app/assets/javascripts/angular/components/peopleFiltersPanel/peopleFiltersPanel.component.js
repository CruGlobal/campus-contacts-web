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
        vm.assignmentOptions = [];
        vm.labelOptions = [];
        vm.labelFilterCollapsed = true;
        vm.assignedToFilterCollapsed = true;
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
                vm.assignmentOptions = resp.data.assigned_tos;
                vm.groupOptions = resp.data.groups;
            });
        }

        // Return the an array of an dictionary's keys that have a truthy value
        function getTruthyKeys (dictionary) {
            return _.chain(dictionary)
                .pickBy()
                .keys()
                .value();
        }

        function cleanUpFilters () {
            var normalizedFilters = { searchString: vm.filters.searchString };
            normalizedFilters.labels = getTruthyKeys(vm.filters.labels);
            normalizedFilters.assignedTos = getTruthyKeys(vm.filters.assigned_tos);
            normalizedFilters.groups = getTruthyKeys(vm.filters.groups);
            return normalizedFilters;
        }
    }
})();
