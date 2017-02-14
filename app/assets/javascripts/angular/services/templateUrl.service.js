(function () {
    'use strict';

    angular.module('missionhubApp').factory('templateUrl', templateUrlService);

    function templateUrlService ($filter) {
        return function (componentName) {
            return $filter('assetPath')('angular/components/' + componentName + '/' + componentName + '.html');
        };
    }
})();
