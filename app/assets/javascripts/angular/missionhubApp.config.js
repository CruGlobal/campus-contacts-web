(function() {
    'use strict';

    angular
        .module('missionhubApp')
        .config(function(envServiceProvider) {
            //TODO: Remove eslint comment when bug is fixed. See https://github.com/Gillespie59/eslint-plugin-angular/issues/223
            envServiceProvider.config({ // eslint-disable-line angular/module-getter
                domains: {
                    development: ['localhost', 'missionhub.local'],
                    staging: ['stage.missionhub.com'],
                    production: ['missionhub.com']
                },
                vars: {
                    development: {
                        apiUrl: '//localhost:3001/apis/v4'
                    },
                    staging: {
                        apiUrl: 'https://api.stage.missionhub.com/apis/v4'
                    },
                    production: {
                        apiUrl: 'https://api.missionhub.com/apis/v4'
                    }
                }
            });

            // run the environment check, so the comprobation is made
            // before controllers and services are built
            envServiceProvider.check();
        });

})();
