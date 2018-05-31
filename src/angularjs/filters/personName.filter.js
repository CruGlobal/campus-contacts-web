/*
 * The personName filter takes a person and converts it into the person's name.
 */
angular.module('missionhubApp')
    .filter('personName', function (_) {
        return function (person) {
            if (!person) {
                return null;
            }

            // Ignore missing name parts
            return [person.first_name, person.last_name].filter(_.identity).join(' ');
        };
    });
