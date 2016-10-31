(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .run(function (lscache, nativeLocation, $analytics) {
            lscache.setBucket('missionhub:');

            if(nativeLocation.pathname !== '/') {
                $analytics.pageTrack(nativeLocation.pathname);
            }
        });

})();
