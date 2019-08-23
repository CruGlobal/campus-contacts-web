angular.module('missionhubApp').filter('assignedPersonName', function(_) {
    return function(person) {
        // This check is needed because I was recieving person.last_name[0] is not defined
        if (!person || !person.last_name) {
            return null;
        }

        // Ignore missing name parts
        return [person.first_name, person.last_name[0]]
            .filter(_.identity)
            .join(' ');
    };
});
