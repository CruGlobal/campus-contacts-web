(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('peopleFiltersPanel', {
            controller: peopleFiltersPanelController,
            templateUrl: '/assets/angular/components/peopleFiltersPanel/peopleFiltersPanel.html',
            bindings: {
                filtersChanged: '&'
            }
        });

    function peopleFiltersPanelController ($scope, _) {
        var vm = this;
        vm.filters = {};

        vm.$onInit = activate;

        function activate () {
            $scope.$watch('$ctrl.filters', function (newFilters, oldFilters) {
                if (!_.isEqual(newFilters, oldFilters)) {
                    vm.filtersChanged({ filters: vm.filters });
                }
            }, true);
        }
    }
})();
