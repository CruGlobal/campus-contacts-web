(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .controller('MenuController', MenuController);

    function MenuController ($window, _) {
        var vm = this;

        $window.location.search.slice(1)
            // Break up querystring into its individual parameters
            .split('&')
            // Look for beta=0 or beta=1
            .map(function (part) {
                return /^beta=(0|1)$/.exec(part);
            })
            // Filter out null non-matches
            .filter(_.identity)
            // Update beta mode
            .forEach(function (matches) {
                var betaMode = matches[1];
                if (betaMode === '0') {
                    // Disable beta mode
                    $window.localStorage.removeItem('beta');
                } else if (betaMode === '1') {
                    // Enable beta mode
                    $window.localStorage.setItem('beta', true);
                }
            });

        vm.betaMode = $window.localStorage.getItem('beta') !== null;
    }
})();
