angular.module('missionhubApp').service('localStorageService', () => {
    var storage = {
        set: function(key, value) {
            localStorage.setItem(key, value);
        },
        get: function(key) {
            var value = localStorage.getItem(key);

            if (value == 'true' || value == 'false') {
                return JSON.parse(value);
            }

            return value;
        },
        destroy: function(key) {
            localStorage.removeItem(key);
        },
        clear: function() {
            localStorage.clear();
        },
    };

    return storage;
});
