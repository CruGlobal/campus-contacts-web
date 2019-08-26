/*
 * The personName filter takes a person and converts it into the person's name.
 */
angular.module('missionhubApp').filter('personName', function(_) {
    return function(person, type) {
        if (!person) {
            return null;
        }
        // If there is no type, filter as normal
        if (!type) {
            // Ignore missing name parts
            return [person.first_name, person.last_name]
                .filter(_.identity)
                .join(' ');
        }
        if (type === 'firstChar' && person.last_name) {
            // Return just the first character of the users last name
            return [person.first_name, person.last_name.charAt(0)]
                .filter(_.identity)
                .join(' ');
        }
    };
});
