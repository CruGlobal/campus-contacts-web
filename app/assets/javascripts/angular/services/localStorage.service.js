angular
    .module('missionhubApp')
    .service('localStorageService', ($window, $location) => {
        const transferSession = event => {
            const newEvent = event ? event : $window.event;

            if (!newEvent.newValue) return;

            if (newEvent.key === 'getSessionStorage') {
                localStorage.setItem(
                    'sessionStorage',
                    angular.toJson(sessionStorage),
                );
                localStorage.removeItem('sessionStorage');
            } else if (
                newEvent.key === 'sessionStorage' &&
                !sessionStorage.length
            ) {
                const data = angular.fromJson(newEvent.newValue);

                for (var key in data) {
                    sessionStorage.setItem(key, data[key]);
                }

                $window.location.reload();
            }
        };

        const storage = {
            set: (key, value) => {
                localStorage.setItem(key, angular.toJson(value));
            },
            get: key => {
                const value = localStorage.getItem(key);
                return angular.fromJson(value);
            },
            destroy: key => {
                localStorage.removeItem(key);
            },
            clear: () => {
                localStorage.clear();
            },
            // This method when initialized, passes the current sessionStorage to new tab instances.
            // Normally new tabs will not keep the sessionStorage.
            allowSessionTransfer: () => {
                localStorage.setItem('getSessionStorage', Date.now());

                if ($window.addEventListener) {
                    $window.addEventListener('storage', transferSession, false);
                } else {
                    $window.attachEvent('onstorage', transferSession);
                }
            },
        };

        return storage;
    });
