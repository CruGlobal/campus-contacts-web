/**
 * Created by eijeh on 9/2/16.
 */


(function () {

    'use strict';

    angular
        .module('missionhubApp')
        .factory('myContactsDashboardService', myContactsDashboardService);


    function myContactsDashboardService (httpProxy, apiEndPoint, loggedInPerson, periodService, _) {

        var myContactsDashboardService = {

            loadPeople: function (params) {
                return httpProxy.get(apiEndPoint.people.index, params || {});
            },

            loadPeopleReports: function (model) {
                return httpProxy.get(apiEndPoint.reports.people, {
                    period: periodService.getPeriod(),
                    organization_ids: model.organization_ids.join(','),
                    people_ids: model.people_ids.join(',')
                });
            },

            loadOrganizations: function (params) {
                return httpProxy.get(apiEndPoint.organizations.index, _.extend({
                    order: 'active_people_count',
                    include: ''
                }, params)).then(httpProxy.extractModels);
            },

            // Modify the user's preferences and save those changes on the server
            updateUserPreference: function (changedPreferences) {
                return httpProxy.put(apiEndPoint.users.me, null, {
                    data: {
                        type: 'user',
                        attributes: changedPreferences
                    }
                });
            },

            // Toggle the organization's visibility
            toggleOrganizationVisibility: function (organization) {
                organization.visible = !organization.visible;

                var hiddenOrgs = loggedInPerson.person.user.hidden_organizations || [];
                if (organization.visible) {
                    // The organization is now visible, so remove it from the user's list of hidden organizations
                    hiddenOrgs = _.remove(hiddenOrgs, organization.id);
                }
                else {
                    // The organization is now hidden, so add it to the user's list of hidden organizations
                    hiddenOrgs.push(organization.id);
                }

                // Commit the changes
                myContactsDashboardService.updateUserPreference({
                    hidden_organizations: hiddenOrgs
                });
            }
        };

        return myContactsDashboardService;
    }

})();
