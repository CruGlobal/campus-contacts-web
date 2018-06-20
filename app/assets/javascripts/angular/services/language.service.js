angular.module('missionhubApp').factory('languageService', languageService);

function languageService() {
    var service = {
        loadLanguages: function() {
            return [
                {
                    abbreviation: 'en',
                    description: 'English',
                },
                {
                    abbreviation: 'ca',
                    description: 'English - Canadian',
                },
                {
                    abbreviation: 'ru',
                    description: 'Russian',
                },
                {
                    abbreviation: 'es',
                    description: 'Spanish',
                },
                {
                    abbreviation: 'es-419',
                    description: 'Spanish - Latin America and Caribbean',
                },
                {
                    abbreviation: 'fr',
                    description: 'French',
                },
                {
                    abbreviation: 'fr-CA',
                    description: 'French - Canadian',
                },
                {
                    abbreviation: 'zh',
                    description: 'Chinese',
                },
                {
                    abbreviation: 'bs',
                    description: 'Bosnian',
                },
                {
                    abbreviation: 'de',
                    description: 'German',
                },
            ];
        },
    };
    return service;
}
