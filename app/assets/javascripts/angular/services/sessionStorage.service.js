angular.module('missionhubApp').service('sessionStorageService', () => {
    const storage = {
        set: (key, value) => {
            sessionStorage.setItem(key, angular.toJson(value));
        },
        get: key => {
            const value = sessionStorage.getItem(key);
            return angular.fromJson(value);
        },
        destroy: key => {
            sessionStorage.removeItem(key);
        },
        clear: () => {
            sessionStorage.clear();
        },
    };

    return storage;
});
