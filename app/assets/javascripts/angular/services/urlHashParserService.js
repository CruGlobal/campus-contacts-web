angular
    .module('missionhubApp')
    .factory('urlHashParserService', urlHashParserService);

function urlHashParserService($location) {
    return {
        param: name => {
            return $location
                .hash()
                .split('&')
                .reduce((acc, v) => {
                    const found = v.split('=').find(f => {
                        return f === name;
                    });

                    if (found === name) {
                        return v.split('=')[1];
                    }

                    return acc;
                }, false);
        },
    };
}
