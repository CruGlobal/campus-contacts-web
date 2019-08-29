/*
 * The personName filter takes a person and converts it into the person's name.
 */
angular.module('missionhubApp').filter('personName', function(_) {
    return function(person, type) {
        if (!person) {
            return null;
        }

        return [
            person.first_name,
            type === 'firstAndLastInitial' && person.last_name
                ? person.last_name.charAt(0)
                : person.last_name,
        ]
            .filter(_.identity)
            .join(' ');
    };
});
