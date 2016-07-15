(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .run(function (lscache) {
            lscache.setBucket('missionhub:');
        });

})();
