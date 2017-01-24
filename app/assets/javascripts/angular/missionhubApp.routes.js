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
                        rootOrgs: function (myOrganizationsDashboardService, orgSorter, $q, $state) {
                            var orgs = orgSorter.sort(myOrganizationsDashboardService.getRootOrganizations());
                            if (orgs.length === 1) {
                                $state.go('app.ministries.ministry.' + ministryViewDefaultTab, { orgId: orgs[0].id });
                                return $q.reject('cancel transition, re-route user to root org.');
                            }
                            return $q.resolve(orgs);
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

            var modalInstance = null;
            $stateProvider.state({
                name: 'app.people.person',
                url: '/:orgId/:personId',
                abstract: true,
                onEnter: function ($state, $stateParams, $uibModal, routesService) {
                    modalInstance = $uibModal.open({
                        animation: true,
                        component: 'personPageModal',
                        resolve: {
                            person: function () {
                                return routesService.getPerson($stateParams.personId);
                            },
                            organizationId: function () {
                                return $stateParams.orgId;
                            }
                        },
                        windowClass: 'dashboard_panels pivot_theme'
                    });

                    // finally would be ideal here, but we need access to the resolved or rejected value, which finally
                    // does not provide.
                    // promise.catch(function (result) { return result; }).then(function (result) { ... }) simulates
                    // promise.finally(function (result) { ... })
                    // If modalInstance.result is a rejected promise, convert it into a resolved promise
                    modalInstance.result.catch(_.identity).then(function (result) {
                        modalInstance = null;

                        if (result.$value && result.$value.fromRouteChange) {
                            // The modal was closed as a result of a route change, so we should not modify the route
                            return;
                        }

                        $state.go('^.^');
                    });
                },
                onExit: function () {
                    if (modalInstance) {
                        modalInstance.close({ $value: { fromRouteChange: true } });
                    }
                }
            })
            .state({
                name: 'app.people.person.defaultTab',
                redirectTo: 'app.people.person.' + personDefaultTab
            });

            // A dictionary of extra resolves needed by each component
            // The key is the tab name and the name is a dictionary of extra resolves
            var personTabResolves = {
                history: {
                    history: function ($stateParams, routesService) {
                        return routesService.getHistory($stateParams.personId);
                    }
                }
            };

            personTabs.forEach(function (tab) {
                $stateProvider.state({
                    name: 'app.people.person.' + tab,
                    url: '/' + tab,
                    resolve: _.extend({}, personTabResolves[tab]),
                    views: {
                        'personTab@': {
                            component: 'person' + _.capitalize(tab)
                        }
                    }
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
                    resolve: _.extend({}, personTabResolves[tab]),
                    views: {
                        personTab: {
                            component: 'person' + _.capitalize(tab)
                        }
                    }
                });
            });

            // This is the default URL if the URL does not match any routes
            $urlRouterProvider.otherwise('/people');
        });
})();
