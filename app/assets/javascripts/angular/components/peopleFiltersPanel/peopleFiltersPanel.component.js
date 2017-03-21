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
            assignedTos: {},
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

            loadFilterStats();

            $scope.$on('massEditApplied', function () {
                loadFilterStats();
            });
        }

        function loadFilterStats () {
            return httpProxy.get(modelsService.getModelMetadata('filter_stats').url.single('people'), {
                organization_id: vm.organizationId
            })
                .then(httpProxy.extractModel)
                .then(function (stats) {
                    vm.labelOptions = stats.labels;
                    vm.assignmentOptions = stats.assigned_tos;
                    vm.groupOptions = stats.groups;

                    // Restrict the active filters to currently valid options
                    // A filter could include a non-existent label, for example, if people were edited so that no one
                    // has that label anymore
                    vm.filters.labels = _.pick(vm.filters.labels, _.map(vm.labelOptions, 'label_id'));
                    vm.filters.assignedTos = _.pick(vm.filters.assignedTos, _.map(vm.assignmentOptions, 'person_id'));
                    vm.filters.groups = _.pick(vm.filters.groups, _.map(vm.groupOptions, 'group_id'));
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
