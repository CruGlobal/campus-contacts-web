(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .directive('exposeSelect', function () {
            return {
                controller: function ($scope) {
                    // Put the $select instance from the ui-select component on the parent scope so that the parent of
                    // ui-select will have access to it
                    $scope.$parent.$select = $scope.$select;
                }
            };
        });
})();
