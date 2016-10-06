(function () {
    'use strict';

    if (location.pathname !== '/') {
        // Only set up client-side routing on the single-page app page
        return;
    }

    angular
        .module('missionhubApp')
        .config(function ($stateProvider, $urlRouterProvider, ministryViewTabs, _) {
            $stateProvider
                .state({
                    name: 'app',
                    url: '',
                    abstract: true,
                    resolve: {
                        person: function (loggedInPerson) {
                            return loggedInPerson.loadingPromise;
                        }
                    },
                    template: '<ui-view></ui-view>'
                })
                .state({
                    name: 'app.people',
                    url: '/people',
                    template:
                        '<my-contacts-dashboard edit-mode="$ctrl.editOrganizations"></my-contacts-dashboard>'
                })
                .state({
                    name: 'app.ministries',
                    url: '/ministries',
                    abstract: true,
                    template:
                        '<my-organizations-dashboard edit-mode="$ctrl.editOrganizations"></my-organizations-dashboard>'
                })
                .state({
                    name: 'app.ministries.root',
                    url: '/root',
                    template:
                        '<organization-overview ng-repeat="org in $ctrl.rootOrgs" org="org" load-details="false">' +
                        '</organization-overview>',
                    controller: function (rootOrgs) {
                        this.rootOrgs = rootOrgs;
                    },
                    controllerAs: '$ctrl',
                    resolve: {
                        rootOrgs: function (myOrganizationsDashboardService, orgSorter) {
                            return orgSorter.sort(myOrganizationsDashboardService.getRootOrganizations());
                        }
                    }
                })
                .state({
                    name: 'app.ministries.ministry',
                    url: '/:orgId',
                    component: 'organizationOverview',
                    abstract: true,
                    resolve: {
                        org: function ($state, $stateParams, JsonApiDataStore) {
                            var org = JsonApiDataStore.store.find('organization', $stateParams.orgId);
                            if (!org) {
                                // Go to the root organization if the organization could not be found
                                $state.go('app.ministries.root');
                            }
                            return org;
                        }
                    }
                });

            ministryViewTabs.forEach(function (tab) {
                $stateProvider.state({
                    name: 'app.ministries.ministry.' + tab,
                    url: '/' + tab,
                    component: 'organizationOverview' + _.capitalize(tab)
                });
            });

            // This is the default URL if the URL does not match any routes
            $urlRouterProvider.otherwise('/people');
        });

})();
