(function () {
    'use strict';

    if (location.pathname !== '/') {
        // Only set up client-side routing on the single-page app page
        return;
    }

    angular
        .module('missionhubApp')
        .config(function ($stateProvider, $urlRouterProvider,
                          ministryViewTabs, ministryViewDefaultTab, personTabs, personDefaultTab, _) {
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
                        '<my-people-dashboard edit-mode="$ctrl.editOrganizations"></my-people-dashboard>'
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
                        org: function ($state, $stateParams, routesService) {
                            return routesService.getOrganization($stateParams.orgId).catch(function () {
                                // Go to the root organization if the organization could not be loaded
                                $state.go('app.ministries.root');
                            });
                        }
                    }
                })
                .state({
                    name: 'app.ministries.ministry.defaultTab',
                    redirectTo: 'app.ministries.ministry.' + ministryViewDefaultTab
                });

            ministryViewTabs.forEach(function (tab) {
                $stateProvider.state({
                    name: 'app.ministries.ministry.' + tab,
                    url: '/' + tab,
                    component: 'organizationOverview' + _.capitalize(tab)
                });
            });

            $stateProvider.state({
                name: 'app.ministries.ministry.people.person',
                url: '/:personId',
                component: 'personPage',
                abstract: true,
                resolve: {
                    person: function ($state, $stateParams, routesService) {
                        return routesService.getPerson($stateParams.personId).catch(function () {
                            // Go back to the parents list if the person could not be found
                            $state.go('app.ministries.ministry.people', { orgId: $stateParams.orgId });
                        });
                    },

                    organizationId: function ($stateParams) {
                        return $stateParams.orgId;
                    }
                }
            })
            .state({
                name: 'app.ministries.ministry.people.person.defaultTab',
                redirectTo: 'app.ministries.ministry.people.person.' + personDefaultTab
            });

            personTabs.forEach(function (tab) {
                $stateProvider.state({
                    name: 'app.ministries.ministry.people.person.' + tab,
                    url: '/' + tab,
                    component: 'person' + _.capitalize(tab),
                    resolve: {
                        history: function ($stateParams, routesService) {
                            return routesService.getHistory($stateParams.personId);
                        }
                    }
                });
            });

            // This is the default URL if the URL does not match any routes
            $urlRouterProvider.otherwise('/people');
        });
})();
