(function () {
    angular
        .module('missionhubApp')
        .factory('orgSorter', orgSorter);

    function orgSorter (loggedInPerson, _) {
        return {
            // Sort the organization array according to the user's preferred sort order`
            sort: function (orgs) {
                // Sort by ancestry then by name
                var sortedOrgs = _.orderBy(orgs, ['ancestry', 'name']);

                // Afterwards, sort by the array of the organization ids in the user's profile
                var orgOrderPreference = loggedInPerson.person.user.organization_order || [];

                // Remove the organizations in orgOrderPreference one by one, placing them in the head array
                var head = [];
                _.each(orgOrderPreference, function (orgId) {
                    head = head.concat(_.remove(sortedOrgs, { id: orgId }));
                });

                // Then move all of the organizations in head to the beginning of the organizations list
                // Any organizations that were not moved will still be sorted by ancestry and name
                return head.concat(sortedOrgs);
            }
        };
    }
})();
