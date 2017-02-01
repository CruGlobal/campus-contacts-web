(function () {
    'use strict';

    if (location.pathname !== '/') {
        // Only set up client-side routing on the single-page app page
        return;
    }

    angular
        .module('missionhubApp')
        .config(function ($stateProvider, $urlRouterProvider, $uibResolveProvider,
                          ministryViewTabs, ministryViewDefaultTab, personTabs, personDefaultTab, _) {
            // Hack $stateProvider.state to support a custom state property "modal" that turns the state into a modal
            // dialog. An Angular decorator would be preferable, but there is no way of decorating a provider.
            var originalState = $stateProvider.state;
            $stateProvider.state = function (state) {
                var transform = state.modal ? modalState : _.identity;
                return originalState(transform(state));
            };

            // Add a states helper method that defines an array of states all at once
            $stateProvider.states = function (states) {
                states.forEach(function (state) {
                    $stateProvider.state(state);
                });
                return $stateProvider;
            };

            // Use the ui-router resolver so that we can correctly resolve ui-router injectables like $stateParams in
            // $uibModal resolve blocks.
            $uibResolveProvider.setResolver('$resolve');

            // Return the parent state name of a ui-router state name
            function getParentState (stateName) {
                // Drop the last part of the state to get the parent state
                return _.chain(stateName)
                    .split('.')
                    .initial()
                    .join('.')
                    .value();
            }

            // Convert a normal ui-router state definition into a state representing a modal dialog
            function modalState (state) {
                var modalInstance = null;
                var closedByRouteChange;
                return {
                    name: state.name,
                    url: state.url,
                    abstract: state.abstract,
                    onEnter: function ($state, $uibModal) {
                        closedByRouteChange = false;
                        modalInstance = $uibModal.open({
                            animation: true,
                            component: state.component,
                            resolve: state.resolve,
                            windowClass: 'dashboard_panels pivot_theme'
                        });

                        modalInstance.result.finally(function () {
                            modalInstance = null;

                            if (closedByRouteChange) {
                                // The modal was closed as a result of a route change, so we should not modify the route
                                return;
                            }

                            $state.go(getParentState(state.name));
                        });
                    },
                    onExit: function () {
                        if (modalInstance) {
                            closedByRouteChange = true;
                            modalInstance.close();
                        }
                    }
                };
            }

            // A dictionary of extra resolves needed by each component
            // The key is the tab name and the name is a dictionary of extra resolves
            var personTabResolves = {
                history: {
                    history: function ($stateParams, routesService) {
                        return routesService.getHistory($stateParams.personId);
                    }
                }
            };

            // Generate and return an array of the states needed for the personPage component
            // The "state" parameter is the state definition that will contain the person page, including its tabs
            function generatePersonPageStates (state) {
                var states = [];

                // Generate the container state
                states.push({
                    name: state.name,
                    url: state.url,
                    component: state.modal ? 'personPageModal' : 'personPage',
                    abstract: true,
                    modal: state.modal,
                    resolve: {
                        person: function ($state, $stateParams, routesService) {
                            return routesService.getPerson($stateParams.personId).catch(function () {
                                // Go back to the parent state if the person could not be found
                                $state.go(getParentState(state.name), { orgId: $stateParams.orgId });
                            });
                        },

                        organizationId: function ($stateParams) {
                            return $stateParams.orgId;
                        }
                    }
                });

                // Generate a state for each tab
                personTabs.forEach(function (tab) {
                    var personTabView = {
                        component: 'person' + _.capitalize(tab)
                    };
                    states.push({
                        name: state.name + '.' + tab,
                        url: '/' + tab,
                        resolve: _.extend({}, personTabResolves[tab]),
                        views: state.modal ? { 'personTab@': personTabView } : { personTab: personTabView }
                    });
                });

                // Generate the default tab state
                states.push({
                    name: state.name + '.defaultTab',
                    redirectTo: state.name + '.' + personDefaultTab
                });

                return states;
            }

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
                })
                .states(ministryViewTabs.map(function (tab) {
                    return {
                        name: 'app.ministries.ministry.' + tab,
                        url: '/' + tab,
                        component: 'organizationOverview' + _.capitalize(tab)
                    };
                }))
                .states(generatePersonPageStates({
                    name: 'app.people.person',
                    url: '/:orgId/:personId',
                    modal: true
                }))
                .states(generatePersonPageStates({
                    name: 'app.ministries.ministry.team.person',
                    url: '/:personId',
                    modal: true
                }))
                .states(generatePersonPageStates({
                    name: 'app.ministries.ministry.people.person',
                    url: '/:personId',
                    modal: false
                }));

            // This is the default URL if the URL does not match any routes
            $urlRouterProvider.otherwise('/people');
        });
})();
