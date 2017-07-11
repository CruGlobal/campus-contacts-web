(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('peopleFiltersPanel', {
            controller: peopleFiltersPanelController,
            templateUrl: /* @ngInject */ function (templateUrl) {
                return templateUrl('peopleFiltersPanel');
            },
            bindings: {
                filtersChanged: '&',
                organizationId: '='
            }
        });

    function peopleFiltersPanelController ($scope, httpProxy, modelsService, peopleFiltersPanelService, _) {
        var vm = this;
        vm.filters = null;
        vm.filtersApplied = false;
        vm.groupOptions = [];
        vm.assignmentOptions = [];
        vm.labelOptions = [];
        vm.labelFilterCollapsed = true;
        vm.assignedToFilterCollapsed = true;
        vm.groupFilterCollapsed = true;

        vm.resetFilters = resetFilters;

        vm.$onInit = activate;

        function activate () {
            $scope.$watch('$ctrl.filters', function (newFilters, oldFilters) {
                if (!_.isEqual(newFilters, oldFilters)) {
                    vm.filtersApplied = peopleFiltersPanelService.filtersHasActive(getNormalizedFilters());

                    sendFilters();
                }
            }, true);

            vm.resetFilters();

            loadFilterStats();

            $scope.$on('massEditApplied', function () {
                loadFilterStats();
            });
        }

        function resetFilters () {
            vm.filters = {
                searchString: '',
                labels: {},
                assignedTos: {},
                groups: {}
            };
        }

        // Send the filters to this component's parent via the filtersChanged binding
        function sendFilters () {
            vm.filtersChanged({ filters: getNormalizedFilters() });
        }

        function loadFilterStats () {
            return httpProxy.get(modelsService.getModelMetadata('filter_stats').url.single('people'), {
                organization_id: vm.organizationId,
                include_unassigned: true
            }, {
                errorMessage: 'error.messages.people_filters_panel.load_filter_stats'
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

        function getNormalizedFilters () {
            return {
                searchString: vm.filters.searchString,
                labels: getTruthyKeys(vm.filters.labels),
                assignedTos: getTruthyKeys(vm.filters.assigned_tos),
                groups: getTruthyKeys(vm.filters.groups)
            };
        }
    }
})();
