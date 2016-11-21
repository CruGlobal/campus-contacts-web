/**
 * Created by eijeh on 9/26/16.
 */

(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('languageService', languageService);

    function languageService () {
        var service = {
            loadLanguages: function () {
                return [
                    {
                        abbreviation: 'en',
                        description: 'English'
                    },
                    {
                        abbreviation: 'ca',
                        description: 'English - Canadian'
                    },
                    {
                        abbreviation: 'ru',
                        description: 'Russian'
                    },
                    {
                        abbreviation: 'es',
                        description: 'Spanish'
                    },
                    {
                        abbreviation: 'fr',
                        description: 'French'
                    },
                    {
                        abbreviation: 'qb',
                        description: 'French - Canadian'
                    },
                    {
                        abbreviation: 'zh',
                        description: 'Chinese'
                    },
                    {
                        abbreviation: 'bs',
                        description: 'Bosnian'
                    },
                    {
                        abbreviation: 'de',
                        description: 'German'
                    }
                ];
            }
        };
        return service;
    }
})();
