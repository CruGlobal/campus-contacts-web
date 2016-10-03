(function () {
    angular
        .module('missionhubApp')
        .factory('periodService', periodService);

    // This service contains action logic that is shared across components
    function periodService ($window, $rootScope) {
        var defaultPeriod = 'P3M';
        var period = null;
        var changeEventName = 'periodService.period-change';

        // Load the report period from localStorage
        function loadPeriod () {
            try {
                period = $window.localStorage.getItem('reportPeriod') || defaultPeriod;
            } catch (e) {
                period = defaultPeriod;
            }
        }

        // Save the report period to localStorage
        function savePeriod () {
            try {
                $window.localStorage.setItem('reportPeriod', period);
            } catch (e) {
                // Period cannot be saved
            }
        }

        loadPeriod();

        return {
            // Return the current report period
            getPeriod: function () {
                return period;
            },

            // Set the current report period
            setPeriod: function (newPeriod) {
                period = newPeriod;
                $rootScope.$emit(changeEventName, newPeriod);
                savePeriod();
            },

            // Request that a callback be called withenver the period changes
            subscribe: function ($scope, callback) {
                var unsubscribe = $rootScope.$on(changeEventName, callback);
                $scope.$on('$destroy', unsubscribe);
            }
        };
    }
})();
