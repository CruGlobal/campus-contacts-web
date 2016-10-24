(function () {
    angular
        .module('missionhubApp')
        .factory('modelsService', modelsService);

    function modelsService () {
        function generateUrls (root) {
            return {
                // The base URL
                root: root,

                // The URL for a single model
                single: function (id) {
                    return root + '/' + id;
                },

                // The URL for all models
                all: root
            };
        }

        var modelMetadata = {
            person: {
                include: 'people',
                url: generateUrls('/people')
            },
            email_address: {
                include: 'email_addresses',
                url: generateUrls('/email_addresses')
            },
            phone_number: {
                include: 'phone_numbers',
                url: generateUrls('/phone_numbers')
            }
        };

        return {
            // Return the metadata for a particular model
            getModelMetadata: function (model) {
                return modelMetadata[model];
            }
        };
    }
})();
