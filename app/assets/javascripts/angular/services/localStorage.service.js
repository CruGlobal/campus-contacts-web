angular.module('missionhubApp').service('localStorageService', () => {
    const storage = {
        set: (key, value) => {
            localStorage.setItem(key, value);
        },
        get: key => {
            var value = localStorage.getItem(key);
            return angular.fromJson(value);
        },
        destroy: key => {
            localStorage.removeItem(key);
        },
        clear: () => {
            localStorage.clear();
        },
    };

    return storage;
});
