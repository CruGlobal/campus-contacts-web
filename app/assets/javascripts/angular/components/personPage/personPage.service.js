(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('personPageService', personPageService);

    function personPageService (httpProxy, modelsService, _) {
        return {
            // Determine whether an avatar URL comes from Facebook
            isFacebookAvatar: function (avatarUrl) {
                return _.startsWith(avatarUrl, 'https://graph.facebook.com/');
            },

            // Upload an image file as the person's new avatar
            uploadAvatar: function (person, file) {
                var url = modelsService.getModelUrl(person);
                var form = {
                    data: {
                        attributes: {
                            picture: file
                        }
                    }
                };
                return httpProxy.submitForm('PUT', url, form);
            },

            // Delete a person's existing avatar
            deleteAvatar: function (person) {
                return httpProxy.put(modelsService.getModelUrl(person), {
                    data: {
                        type: 'person',
                        id: person.id,
                        attributes: {
                            picture: null
                        }
                    }
                });
            }
        };
    }
})();
