import '../../../../src/community/stats/communityStats';

angular
    .module('missionhubApp')
    .config(function(
        $stateProvider,
        $locationProvider,
        $urlServiceProvider,
        $uibResolveProvider,
        asyncBindingsServiceProvider,
        ministryViewTabs,
        ministryViewDefaultTab,
        personTabs,
        personDefaultTab,
        _,
    ) {
        // Instantiate factories
        var asyncBindingsService = asyncBindingsServiceProvider.$get();

        // Convenience alias
        var lazyLoadedResolve = asyncBindingsService.lazyLoadedResolve;

        // Hack $stateProvider.state to support a custom state property "modal" that turns the state into a modal
        // dialog. An Angular decorator would be preferable, but there is no way of decorating a provider.
        var originalState = $stateProvider.state;
        $stateProvider.state = function(state) {
            var transform = state.modal ? modalState : _.identity;
            return originalState(transform(state));
        };

        // Add a states helper method that defines an array of states all at once
        $stateProvider.states = function(states) {
            states.forEach(function(state) {
                $stateProvider.state(state);
            });
            return $stateProvider;
        };

        // Use the ui-router resolver so that we can correctly resolve ui-router injectables like $transition$ in
        // $uibModal resolve blocks.
        $uibResolveProvider.setResolver('$resolve');

        // Return the parent state name of a ui-router state name
        function getParentState(stateName) {
            // Drop the last part of the state to get the parent state
            return _.chain(stateName)
                .split('.')
                .initial()
                .join('.')
                .value();
        }

        // Convert a normal ui-router state definition into a state representing a modal dialog
        function modalState(state) {
            var modalInstance = null;
            var closedByRouteChange;
            return {
                name: state.name,
                url: state.url,
                abstract: state.abstract,
                params: state.params,
                onEnter: /* @ngInject */ function($state, $uibModal) {
                    closedByRouteChange = false;

                    // The final generated template will look like this:
                    // <component-name first-attribute="$ctrl.firstAttribute"
                    //                 second-attribute="$ctrl.secondAttribute"></component-name>
                    var injectedProps = _.keys(state.resolve);
                    var attributes = injectedProps.map(function(property) {
                        return (
                            _.kebabCase(property) + '="$ctrl.' + property + '"'
                        );
                    });
                    var directive = _.kebabCase(state.component);
                    var template =
                        '<' +
                        directive +
                        ' ' +
                        attributes.join(' ') +
                        '></' +
                        directive +
                        '>';

                    modalInstance = $uibModal.open({
                        animation: true,
                        template: template,

                        // Explicitly inject the injected properties as dependencies
                        controller: injectedProps.concat([
                            function() {
                                var vm = this;

                                var injectedValues = arguments;
                                var injections = _.zipObject(
                                    injectedProps,
                                    injectedValues,
                                );
                                _.extend(vm, injections);
                            },
                        ]),
                        controllerAs: '$ctrl',
                        resolve: state.resolve,
                        windowClass: 'dashboard_panels pivot_theme',
                    });

                    modalInstance.result.finally(function() {
                        modalInstance = null;

                        if (closedByRouteChange) {
                            // The modal was closed as a result of a route change, so we should not modify the route
                            return;
                        }

                        $state.go(getParentState(state.name));
                    });
                },
                onExit: function() {
                    if (modalInstance) {
                        closedByRouteChange = true;
                        modalInstance.close();
                    }
                },
            };
        }

        // A dictionary of extra resolves needed by each component
        // The key is the tab name and the name is a dictionary of extra resolves
        var personTabResolves = {
            history: {
                history: lazyLoadedResolve(
                    /* @ngInject */ function($uiRouter, routesService) {
                        var $transition$ = $uiRouter.globals.transition;
                        return routesService.getHistory(
                            $transition$.params().personId,
                        );
                    },
                ),
            },
        };

        // Generate and return an array of the states needed for the personPage component
        // The "state" parameter is the state definition that will contain the person page, including its tabs
        function generatePersonPageStates(state) {
            var states = [];

            // Generate the container state
            states.push({
                name: state.name,
                url: state.url,
                component: 'personPage',
                abstract: true,
                params: _.extend(
                    {
                        assignToMe: { type: 'bool', value: false },
                    },
                    state.params,
                ),
                modal: state.modal,
                resolve: {
                    // We have to send the state name to the personPage component so that route links will work when
                    // the person page is in a modal. Relative ui-state directives work fine when the person page is
                    // a component. However, when it is a modal, apparently the component created by uib-modal does
                    // not know the state that it was created from, so those relative links will all be broken. To
                    // solve this, we send the state name to the component so that it can generate absolute links
                    // based on its current state.
                    stateName: _.constant(state.name),
                    person: lazyLoadedResolve(
                        /* @ngInject */ function(
                            $state,
                            $uiRouter,
                            routesService,
                            personService,
                        ) {
                            // Ideally, we would inject $transition$, an object representing that ui-router makes
                            // available to states' resolves. However, when the state is refers to a state in a modal,
                            // the resolve will not have access to that transition, so we have to get it from the
                            // a ui-router global that is injectable everywhere.
                            var $transition$ = $uiRouter.globals.transition;
                            var params = $transition$.params();

                            if (params.personId === 'new') {
                                // We are creating a new person instead of editing an existing one, so generate that
                                // new person model
                                return personService.getNewPerson(params.orgId);
                            }

                            return routesService
                                .getPerson(params.personId)
                                .catch(function() {
                                    // Go back to the parent state if the person could not be found
                                    $state.go(getParentState(state.name), {
                                        orgId: params.orgId,
                                    });

                                    throw new Error(
                                        'Person could not be loaded',
                                    );
                                });
                        },
                    ),

                    organizationId: lazyLoadedResolve(
                        /* @ngInject */ function($uiRouter) {
                            var $transition$ = $uiRouter.globals.transition;
                            return $transition$.params().orgId;
                        },
                    ),

                    options: /* @ngInject */ function($uiRouter) {
                        var $transition$ = $uiRouter.globals.transition;
                        return {
                            assignToMe: $transition$.params().assignToMe,
                        };
                    },
                },
            });

            // Generate a state for each tab
            personTabs.forEach(function(tab) {
                var personTabView = {
                    component: 'person' + _.capitalize(tab),
                };
                states.push({
                    name: state.name + '.' + tab,
                    url: '/' + tab,
                    resolve: personTabResolves[tab],
                    views: state.modal
                        ? { 'personTab@': personTabView }
                        : { personTab: personTabView },
                });
            });

            // Generate the default tab state
            states.push({
                name: state.name + '.defaultTab',
                redirectTo: state.name + '.' + personDefaultTab,
            });

            return states;
        }

        $stateProvider
            .state({
                name: 'app',
                url: '',
                abstract: true,
                component: 'app',
                resolve: {
                    hideHeader: () => false,
                    hideFooter: () => false,
                    hideMenuLinks: () => false,
                },
            })
            .state({
                name: 'appWithoutMenus',
                url: '',
                abstract: true,
                component: 'app',
                resolve: {
                    hideHeader: () => true,
                    hideFooter: () => true,
                    hideMenuLinks: () => false,
                },
            })
            .state({
                name: 'appWithoutMenuLinks',
                url: '',
                abstract: true,
                component: 'app',
                resolve: {
                    hideHeader: () => false,
                    hideFooter: () => false,
                    hideMenuLinks: () => true,
                },
            })
            .state({
                name: 'app.signIn',
                url: '/sign-in',
                component: 'signIn',
                data: {
                    isPublic: true,
                },
            })
            .state({
                name: 'appWithoutMenuLinks.auth',
                url: '/auth-web?access_token',
                component: 'signIn',
                resolve: {
                    accessToken: ($location, urlHashParserService) => {
                        return urlHashParserService.param('access_token');
                    },
                },
                data: {
                    isPublic: true,
                },
            })
            .state({
                name: 'appWithoutMenuLinks.authLanding',
                url: '/auth',
                component: 'authLanding',
                data: {
                    isPublic: true,
                },
            })
            .state({
                name: 'app.requestAccess',
                url: '/request-access',
                component: 'requestAccess',
                data: {
                    isPublic: true,
                },
            })
            .state({
                name: 'appWithoutMenus.mergeAccount',
                url: '/merge-account/:rememberCode/:orgId/:userId',
                component: 'mergeAccount',
                resolve: {
                    rememberCode: $transition$ =>
                        $transition$.params().rememberCode,
                    userId: $transition$ => $transition$.params().userId,
                    orgId: $transition$ => $transition$.params().orgId,
                    loggedInUser: loggedInPerson => loggedInPerson.load(),
                },
            })
            .state({
                name: 'app.impersonateUser',
                url: '/impersonate-user/:userId',
                component: 'impersonateUser',
                resolve: {
                    userId: ($state, $transition$) =>
                        $transition$.params().userId,
                },
            })
            .state({
                name: 'app.stopImpersonatingUser',
                url: '/stop-impersonation',
                component: 'impersonateUser',
            })
            .state({
                name: 'app.people',
                url: '/people',
                template:
                    '<my-people-dashboard edit-mode="$ctrl.editOrganizations"></my-people-dashboard>',
            })
            .states(
                generatePersonPageStates({
                    name: 'app.people.new',
                    url: '/new?orgId',
                    modal: true,
                    params: {
                        orgId: { value: null },
                        personId: { value: 'new' },
                    },
                }),
            )
            .state({
                name: 'app.ministries',
                url: '/ministries',
                abstract: true,
                template:
                    '<my-organizations-dashboard></my-organizations-dashboard>',
            })
            .state({
                name: 'app.ministries.root',
                url: '/root',
                component: 'myOrganizationsDashboardList',
                resolve: {
                    rootOrgs: function(
                        myOrganizationsDashboardService,
                        userPreferencesService,
                        $q,
                        $state,
                    ) {
                        return myOrganizationsDashboardService
                            .getRootOrganizations()
                            .then(
                                userPreferencesService.applyUserOrgDisplayPreferences,
                            )
                            .then(orgs => {
                                if (orgs.length === 1) {
                                    $state.go(
                                        'app.ministries.ministry.' +
                                            ministryViewDefaultTab,
                                        { orgId: orgs[0].id },
                                    );
                                    return $q.reject(
                                        'cancel transition, re-route user to root org.',
                                    );
                                }
                                return orgs;
                            });
                    },
                },
            })
            .state({
                name: 'app.ministries.signAgreements',
                url: '/sign-agreements',
                component: 'organizationSignaturesSign',
            })
            .state({
                name: 'app.ministries.ministry',
                url: '/:orgId',
                component: 'organizationOverview',
                abstract: true,
                resolve: {
                    org: lazyLoadedResolve(
                        /* @ngInject */ function(
                            $state,
                            $transition$,
                            routesService,
                        ) {
                            return routesService
                                .getOrganization($transition$.params().orgId)
                                .catch(function() {
                                    // Go to the root organization if the organization could not be loaded
                                    $state.go('app.ministries.root');

                                    throw new Error(
                                        'Organization could not be loaded',
                                    );
                                });
                        },
                    ),
                },
            })
            .state({
                name: 'app.ministries.ministry.import',
                url: '/import',
                component: 'organizationContactImport',
                params: {
                    surveyId: null,
                },
                resolve: {
                    surveyId: ($state, $transition$) =>
                        $transition$.params().surveyId,
                },
            })
            .state({
                name: 'app.ministries.ministry.management',
                url: '/management',
                component: 'orgManagement',
            })
            .state({
                name: 'app.ministries.ministry.cleanup',
                url: '/organization-cleanup',
                component: 'organizationCleanup',
                resolve: {
                    orgId: $transition$ => $transition$.params().orgId,
                },
            })
            .state({
                name: 'app.ministries.ministry.signatures',
                url: '/organization-signatures',
                component: 'organizationSignatures',
                resolve: {
                    orgId: $transition$ => $transition$.params().orgId,
                },
            })
            .state({
                name: 'app.ministries.ministry.reportMovementIndicators',
                url: '/report-movement-indicators',
                component: 'reportMovementIndicators',
                resolve: {
                    orgId: $transition$ => $transition$.params().orgId,
                },
            })
            .state({
                name: 'app.ministries.ministry.stats',
                url: '/stats',
                component: 'communityStats',
                resolve: {
                    orgId: $transition$ => $transition$.params().orgId,
                },
            })
            .state({
                name: 'app.ministries.ministry.defaultTab',
                redirectTo: 'app.ministries.ministry.' + ministryViewDefaultTab,
            })
            .states(
                generatePersonPageStates({
                    name: 'app.ministries.ministry.people.new',
                    url: '/new',
                    modal: true,
                    params: {
                        personId: { value: 'new' },
                    },
                }),
            )
            .states(
                ministryViewTabs.map(function(tab) {
                    const formatArrayForFilter = filter => {
                        if (!filter) return {};

                        return filter
                            .split(',')
                            .reduce(
                                (acc, value) => ({ ...acc, [value]: true }),
                                {},
                            );
                    };

                    if (tab === 'people') {
                        return {
                            name: 'app.ministries.ministry.' + tab,
                            url: '/people?statuses=&assigned_to=',
                            component:
                                'organizationOverview' + _.upperFirst(tab),
                            resolve: {
                                queryFilters: /* @ngInject */ (
                                    $transition$,
                                    $location,
                                ) => {
                                    const filters = $location.search();

                                    return {
                                        ...(filters.assigned_to
                                            ? {
                                                  assigned_tos: formatArrayForFilter(
                                                      filters.assigned_to,
                                                  ),
                                              }
                                            : {}),
                                        ...(filters.statuses
                                            ? {
                                                  statuses: formatArrayForFilter(
                                                      filters.statuses,
                                                  ),
                                              }
                                            : {}),
                                    };
                                },
                            },
                        };
                    }

                    return {
                        name: 'app.ministries.ministry.' + tab,
                        url: '/' + tab,
                        component: 'organizationOverview' + _.upperFirst(tab),
                    };
                }),
            )
            .states(
                generatePersonPageStates({
                    name: 'app.people.person',
                    url: '/:orgId/:personId',
                    modal: true,
                }),
            )
            .states(
                generatePersonPageStates({
                    name: 'app.ministries.ministry.team.person',
                    url: '/:personId',
                    modal: true,
                }),
            )
            .states(
                generatePersonPageStates({
                    name: 'app.ministries.ministry.people.person',
                    url: '/:personId',
                    modal: false,
                }),
            )
            .states(
                generatePersonPageStates({
                    name: 'app.ministries.ministry.survey.responses.person',
                    url: '/:personId',
                    modal: false,
                }),
            )
            .state({
                name: 'app.userPreferences',
                url: '/user-preferences',
                template: '<user-preferences></user-preferences>',
                whiteBackground: true,
            })
            .state({
                name: 'publicPhoneNumberValidation',
                url: '/p/:code/:id',
                component: 'publicPhoneNumberValidation',
                data: {
                    isPublic: true,
                },
                resolve: {
                    phoneNumberValidation: (
                        $state,
                        $transition$,
                        routesService,
                    ) => {
                        return routesService
                            .getPhoneNumberValidation(
                                $transition$.params().code,
                                $transition$.params().id,
                            )
                            .catch(e => null);
                    },
                },
            })
            .state({
                name: 'appWithoutMenus.publicSurvey',
                url: '/s/:surveyId?preview',
                component: 'publicSurvey',
                data: {
                    isPublic: true,
                },
                resolve: {
                    survey: ($state, $transition$, routesService) => {
                        return routesService
                            .getSurvey($transition$.params().surveyId)
                            .catch(e => null);
                    },
                    preview: ($state, $transition$) =>
                        !!$transition$.params().preview,
                },
            })
            .state({
                name: 'appWithoutMenus.previewSurvey',
                url: '/previewSurvey/:surveyId',
                component: 'publicSurvey',
                resolve: {
                    survey: ($state, $transition$, routesService) =>
                        routesService.getSurvey($transition$.params().surveyId),
                    preview: () => true,
                },
            })
            .state({
                name: 'appWithoutMenus.inviteLink',
                url: '/l/:rememberCode/:orgId/:userId',
                component: 'inviteLink',
                data: {
                    isPublic: true,
                },
                resolve: {
                    rememberCode: $transition$ =>
                        $transition$.params().rememberCode,
                    userId: $transition$ => $transition$.params().userId,
                    orgId: $transition$ => $transition$.params().orgId,
                },
            })
            .state({
                name: 'app.ministries.ministry.survey',
                url: '/survey/:surveyId',
                abstract: true,
                template: '<ui-view></ui-view>',
                resolve: {
                    survey: ($state, $transition$, routesService) => {
                        return routesService.getSurvey(
                            $transition$.params().surveyId,
                        );
                    },
                },
            })
            .state({
                name: 'app.ministries.ministry.survey.manage',
                url: '/',
                component: 'surveyOverview',
            })
            .state({
                name: 'app.ministries.ministry.survey.responses',
                url: '/responses',
                component: 'surveyResponses',
            });

        // This is the default URL if the URL does not match any routes
        $urlServiceProvider.rules.otherwise('/people');
        $locationProvider.html5Mode(true);
    });
