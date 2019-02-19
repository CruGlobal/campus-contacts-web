angular.module('missionhubApp').factory('loggedInPerson', loggedInPerson);

function loggedInPerson(
    httpProxy,
    modelsService,
    organizationService,
    permissionService,
    _,
) {
    var person = null;
    var loadingPromise = null;

    // Load the logged-in user's profile
    function loadMe() {
        return httpProxy
            .get(
                modelsService.getModelMetadata('person').url.single('me'),
                {
                    include: 'user,organizational_permissions',
                },
                {
                    errorMessage: 'error.messages.logged_in_person.load_user',
                },
            )
            .then(httpProxy.extractModel);
    }

    function load() {
        loadingPromise = loadMe().then(function(me) {
            person = me;
            return me;
        });
        return loadingPromise;
    }

    // This service exposes an object with a person property that will be set to person model, or null if it has
    // not yet been loaded.
    return {
        // Return the person mode, or null if it has not yet been loaded
        get person() {
            return person;
        },

        set person(newPerson) {
            throw new Error('loggedInPerson.person is not settable!');
        },

        get loadingPromise() {
            return loadingPromise;
        },

        // Load (or reload) the person
        load: load,

        loadOnce: function() {
            if (!loadingPromise) {
                load();
            }
            return loadingPromise;
        },

        // check if you have admin access on the org or any above it
        isAdminAt: function(org) {
            var adminOrgIds = _.chain(person.organizational_permissions)
                .filter({ permission_id: permissionService.adminId })
                .map('organization_id')
                .value();
            var orgAndAncestry = organizationService.getOrgHierarchyIds(org);
            return _.intersection(adminOrgIds, orgAndAncestry).length !== 0;
        },

        // check if you have admin access on the org itself. access to any org above it don't count
        isDirectAdminAt: org => {
            return person.organizational_permissions.some(
                ({ permission_id, organization_id }) =>
                    permission_id === permissionService.adminId &&
                    organization_id === org.id,
            );
        },

        updatePreferences: function(preferences) {
            var model = {
                data: {
                    attributes: preferences,
                },
            };
            return httpProxy.put(
                modelsService.getModelMetadata('user').url.single('me'),
                model,
                {
                    errorMessage:
                        'error.messages.preferences_page.update_preferences',
                },
            );
        },
    };
}
