angular
    .module('missionhubApp')
    .factory('preferencesPageService', preferencesPageService);

function preferencesPageService(httpProxy, modelsService, loggedInPerson) {
    return {
        updatePreferences: function(model) {
            return httpProxy.put(
                modelsService.getModelMetadata('user').url.single('me'),
                model,
                {
                    errorMessage:
                        'error.messages.preferences_page.update_preferences',
                },
            );
        },

        readPreferences: function() {
            return loggedInPerson.loadOnce();
        },
    };
}
