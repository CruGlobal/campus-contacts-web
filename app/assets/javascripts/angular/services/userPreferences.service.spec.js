import 'angular-mocks';

// Constants
var userPreferencesService, _;
var httpProxy = jasmine.createSpyObj('httpProxy', ['put']);

describe('userPreferences service', function() {
    beforeEach(function() {
        var _this = this;

        // Mock out the loggedInPerson service
        angular.mock.module(function($provide) {
            $provide.factory('loggedInPerson', function() {
                return {
                    person: {
                        user: {
                            get organization_order() {
                                return _this.orgOrder;
                            },
                            get hidden_organizations() {
                                return _this.hiddenOrgs;
                            },
                        },
                    },
                };
            });

            $provide.factory('httpProxy', function() {
                return httpProxy;
            });
        });
    });

    beforeEach(inject(function(_userPreferencesService_, ___) {
        userPreferencesService = _userPreferencesService_;
        _ = ___;

        // The org order returned by loggedInPerson.person.user.organization_order
        // It be changed by individual tests
        this.orgOrder = null;

        this.orgs = [
            (this.org1 = { id: 1, name: 'Alpha', ancestry: null }),
            (this.org2 = { id: 2, name: 'Charlie', ancestry: '1' }),
            (this.org3 = { id: 3, name: 'Bravo', ancestry: '1' }),
            (this.org4 = { id: 4, name: 'Delta', ancestry: null }),
            (this.org5 = { id: 5, name: 'Echo', ancestry: '4' }),
        ];
    }));

    describe('updateUserPreference', function() {
        it('should save the changed preferences to the server', function() {
            userPreferencesService._updateUserPreferences(
                {
                    somePreference: 'newValue',
                },
                'error message',
            );
            expect(httpProxy.put).toHaveBeenCalledWith(
                '/users/me',
                {
                    data: {
                        type: 'user',
                        attributes: {
                            somePreference: 'newValue',
                        },
                    },
                },
                {
                    errorMessage: 'error message',
                },
            );
        });
    });

    describe('organizationOrderChange', function() {
        it('should save the new organization order', function() {
            jest.spyOn(
                userPreferencesService,
                '_updateUserPreferences',
            ).mockImplementation(() => {});
            userPreferencesService.organizationOrderChange(
                [
                    {
                        id: 2,
                    },
                    {
                        id: 1,
                    },
                ],
                'error message',
            );
            expect(
                userPreferencesService._updateUserPreferences,
            ).toHaveBeenCalledWith(
                {
                    organization_order: [2, 1],
                },
                'error.messages.my_people_dashboard.update_org_order',
            );
        });
    });

    describe('toggleOrganizationVisibility', function() {
        it('should hide an org save the updated hiddenOrgs list', function() {
            jest.spyOn(
                userPreferencesService,
                '_updateUserPreferences',
            ).mockImplementation(() => {});
            this.hiddenOrgs = [4, 5];

            userPreferencesService.toggleOrganizationVisibility({
                id: 2,
                visible: true,
            });
            expect(
                userPreferencesService._updateUserPreferences,
            ).toHaveBeenCalledWith(
                {
                    hidden_organizations: [4, 5, 2],
                },
                'error.messages.my_people_dashboard.update_org_visibility',
            );
        });
    });

    describe('applyUserOrgDisplayPreferences', function() {
        it('should sort by ancestry and name with no org order', function() {
            this.orgOrder = null;
            expect(
                _.map(
                    userPreferencesService.applyUserOrgDisplayPreferences(
                        this.orgs,
                    ),
                    'id',
                ),
            ).toEqual([3, 2, 5, 1, 4]);
        });

        it('should sort by org order with complete org order', function() {
            this.orgOrder = [2, 5, 3, 1, 4];
            expect(
                _.map(
                    userPreferencesService.applyUserOrgDisplayPreferences(
                        this.orgs,
                    ),
                    'id',
                ),
            ).toEqual(this.orgOrder);
        });

        it('should sort by org order then by ancestry and name with incomplete org order', function() {
            this.orgOrder = [2, 5];
            expect(
                _.map(
                    userPreferencesService.applyUserOrgDisplayPreferences(
                        this.orgs,
                    ),
                    'id',
                ),
            ).toEqual([2, 5, 3, 1, 4]);
        });

        it('should handle old user preferences', function() {
            this.orgOrder = [6, 9, 2, 5];
            expect(
                _.map(
                    userPreferencesService.applyUserOrgDisplayPreferences(
                        this.orgs,
                    ),
                    'id',
                ),
            ).toEqual([2, 5, 3, 1, 4]);
        });
    });
});
