(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('modelsService', modelsService);

    function modelsService (_) {
        function generateUrls (root, extras) {
            return _.extend({
                // The base URL
                root: root,

                // The URL for a single model
                single: function (id) {
                    return root + '/' + id;
                },

                // The URL for all models
                all: root
            }, extras);
        }

        var modelMetadata = {
            person: {
                include: 'people',
                url: generateUrls('/people', {
                    search: '/search'
                })
            },
            user: {
                include: 'users',
                url: generateUrls('/users')
            },
            email_address: {
                include: 'email_addresses',
                url: generateUrls('/email_addresses')
            },
            phone_number: {
                include: 'phone_numbers',
                url: generateUrls('/phone_numbers')
            },
            organization: {
                include: 'organizations',
                url: generateUrls('/organizations')
            },
            person_report: {
                include: 'person_reports',
                url: generateUrls('/reports/people')
            },
            organization_report: {
                include: 'organization_reports',
                url: generateUrls('/reports/organizations')
            },
            interaction: {
                include: 'interactions',
                url: generateUrls('/interactions')
            },
            contact_assignment: {
                include: 'contact_assignments',
                url: generateUrls('/contact_assignments')
            },
            group: {
                url: generateUrls('/groups')
            }
        };

        var modelsService = {
            // Return the metadata for a particular model
            getModelMetadata: function (model) {
                return modelMetadata[model];
            },

            // Return the single URL for a model
            getModelUrl: function (model) {
                var metadata = modelsService.getModelMetadata(model._type);
                return metadata && metadata.url.single(model.id);
            }
        };

        return modelsService;
    }
})();
