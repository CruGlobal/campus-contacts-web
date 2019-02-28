import 'angular-mocks';

// Constants
var myPeopleDashboardService, httpProxy, $rootScope, $q, JsonApiDataStore;

function async(fn) {
    return function(done) {
        var returnValue = fn.call(this, done);
        returnValue
            .then(function() {
                done();
            })
            .catch(function(err) {
                done.fail(err);
            });
        $rootScope.$apply();
        return returnValue;
    };
}

describe('myPeopleDashboardService Tests', function() {
    beforeEach(inject(function(
        _$q_,
        _$rootScope_,
        _myPeopleDashboardService_,
        _httpProxy_,
        _JsonApiDataStore_,
    ) {
        var _this = this;

        $q = _$q_;
        $rootScope = _$rootScope_;
        httpProxy = _httpProxy_;
        JsonApiDataStore = _JsonApiDataStore_;
        myPeopleDashboardService = _myPeopleDashboardService_;

        this.person = {
            personId: 123,
        };

        this.people = [
            {
                personId: 123,
            },
            {
                personId: 234,
            },
        ];

        this.organizationReports = {
            reportId: 123,
        };

        this.loadOrganizationParams = {
            'page[limit]': 100,
            sort: '-active_people_count',
            include: '',
            'filters[user_created]': false,
        };

        jest.spyOn(httpProxy, 'callHttp').mockImplementation(function() {
            return $q.resolve(_this.httpResponse);
        });

        jest.spyOn(JsonApiDataStore.store, 'sync').mockReturnValue(
            _this.httpResponse,
        );
    }));
    describe('People Tests', function() {
        it('should contain loadPeople', function() {
            expect(myPeopleDashboardService.loadPeople).toBeDefined();
        });

        it('should call GET loadPeople URL', function() {
            var params = {
                'page[limit]': 250,
                include:
                    'phone_numbers,email_addresses,reverse_contact_assignments.organization,' +
                    'organizational_permissions',
                'filters[assigned_tos]': 'me',
            };
            myPeopleDashboardService.loadPeople(params);
            expect(httpProxy.callHttp).toHaveBeenCalledWith(
                'GET',
                jasmine.any(String),
                params,
                null,
                jasmine.objectContaining({ errorMessage: jasmine.any(String) }),
            );
        });

        it('should load people', async(function() {
            this.httpResponse = this.people;

            var _this = this;
            return myPeopleDashboardService
                .loadPeople()
                .then(function(loadedPeople) {
                    expect(loadedPeople).toEqual(_this.people);
                });
        }));

        it('should sync people JsonApiDataStore', async(function() {
            this.httpResponse = this.people;

            var _this = this;
            JsonApiDataStore.store.sync('people', this.people);
            return myPeopleDashboardService.loadPeople().then(function() {
                expect(JsonApiDataStore.store.sync).toHaveBeenCalledWith(
                    'people',
                    _this.people,
                );
            });
        }));
    });

    describe('Organization loading', function() {
        it('should contain load Organization', function() {
            expect(myPeopleDashboardService.loadOrganizations).toBeDefined();
        });

        it('should call GET loadOrganization URL', function() {
            myPeopleDashboardService.loadOrganizations(
                this.loadOrganizationParams,
            );
            expect(httpProxy.callHttp).toHaveBeenCalledWith(
                'GET',
                jasmine.any(String),
                this.loadOrganizationParams,
                null,
                jasmine.objectContaining({ errorMessage: jasmine.any(String) }),
            );
        });

        it('should load Organization', async(function() {
            this.httpResponse = { data: this.organizationReports };

            var _this = this;

            return myPeopleDashboardService
                .loadOrganizations(this.loadOrganizationParams)
                .then(function(loadedOrganization) {
                    expect(loadedOrganization).toEqual(
                        _this.organizationReports,
                    );
                });
        }));
    });
});
