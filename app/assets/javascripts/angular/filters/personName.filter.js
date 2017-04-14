(function () {
    'use strict';

    /*
     * The personName filter takes a perosn and converts it into the person's name.
     */
    angular.module('missionhubApp')
        .filter('personName', function () {
            return function (person) {
                return person ? person.first_name + ' ' + person.last_name : null;
            };
        });
})();
