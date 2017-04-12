/**
 * Created by eijeh on 9/2/16.
 */

(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('myPeopleDashboardService', myPeopleDashboardService);

    function myPeopleDashboardService (httpProxy, modelsService, loggedInPerson, periodService, _) {
        var myPeopleDashboardService = {
            loadPeople: function (params) {
                return httpProxy.get(modelsService.getModelMetadata('person').url.all, params || {}, {
                    errorMessage: 'error.messages.my_people_dashboard.load_people'
                });
            },

            loadPeopleReports: function (model) {
                return httpProxy.get(modelsService.getModelMetadata('person_report').url.all, {
                    period: periodService.getPeriod(),
                    organization_ids: model.organization_ids.join(','),
                    people_ids: model.people_ids.join(',')
                }, {
                    errorMessage: 'error.messages.my_people_dashboard.load_reports'
                });
            },

            loadOrganizations: function (params) {
                return httpProxy.get(modelsService.getModelMetadata('organization').url.all, _.extend({
                    order: 'active_people_count',
                    include: ''
                }, params), {
                    errorMessage: 'error.messages.my_people_dashboard.load_orgs'
                }).then(httpProxy.extractModels);
            },

            // Modify the user's preferences and save those changes on the server
            updateUserPreference: function (changedPreferences, errorMessage) {
                return httpProxy.put(modelsService.getModelMetadata('user').url.single('me'), {
                    data: {
                        type: 'user',
                        attributes: changedPreferences
                    }
                }, {
                    errorMessage: errorMessage
                });
            },

            // Toggle the organization's visibility
            toggleOrganizationVisibility: function (organization) {
                organization.visible = !organization.visible;

                var hiddenOrgs = loggedInPerson.person.user.hidden_organizations || [];
                if (organization.visible) {
                    // The organization is now visible, so remove it from the user's list of hidden organizations
                    hiddenOrgs = _.remove(hiddenOrgs, organization.id);
                } else {
                    // The organization is now hidden, so add it to the user's list of hidden organizations
                    hiddenOrgs.push(organization.id);
                }

                // Commit the changes
                myPeopleDashboardService.updateUserPreference({
                    hidden_organizations: hiddenOrgs
                }, 'error.messages.my_people_dashboard.update_org_visibility');
            }
        };

        return myPeopleDashboardService;
    }
})();
