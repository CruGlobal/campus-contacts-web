import 'angular-mocks';

// Constants
let myPeopleDashboardService, httpProxy, $rootScope, $q, JsonApiDataStore;

function async(fn) {
  return function (done) {
    const returnValue = fn.call(this, done);
    returnValue
      .then(function () {
        done();
      })
      .catch(function (err) {
        done.fail(err);
      });
    $rootScope.$apply();
    return returnValue;
  };
}

describe('myPeopleDashboardService Tests', function () {
  beforeEach(inject(function (_$q_, _$rootScope_, _myPeopleDashboardService_, _httpProxy_, _JsonApiDataStore_) {
    const _this = this;

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

    spyOn(httpProxy, 'callHttp').and.callFake(function () {
      return $q.resolve(_this.httpResponse);
    });

    spyOn(JsonApiDataStore.store, 'sync').and.returnValue(_this.httpResponse);
  }));
  describe('People Tests', function () {
    it('should contain loadPeople', function () {
      expect(myPeopleDashboardService.loadPeople).toBeDefined();
    });

    it('should call GET loadPeople URL', function () {
      const params = {
        'page[limit]': 250,
        include: 'phone_numbers,email_addresses,reverse_contact_assignments.organization,organizational_permissions',
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

    it('should load people', async(function () {
      this.httpResponse = this.people;

      const _this = this;
      return myPeopleDashboardService.loadPeople().then(function (loadedPeople) {
        expect(loadedPeople).toEqual(_this.people);
      });
    }));

    it('should sync people JsonApiDataStore', async(function () {
      this.httpResponse = this.people;

      const _this = this;
      JsonApiDataStore.store.sync('people', this.people);
      return myPeopleDashboardService.loadPeople().then(function () {
        expect(JsonApiDataStore.store.sync).toHaveBeenCalledWith('people', _this.people);
      });
    }));
  });

  describe('Organization loading', function () {
    it('should contain load Organization', function () {
      expect(myPeopleDashboardService.loadOrganizations).toBeDefined();
    });

    it('should call GET loadOrganization URL', function () {
      myPeopleDashboardService.loadOrganizations(this.loadOrganizationParams);
      expect(httpProxy.callHttp).toHaveBeenCalledWith(
        'GET',
        jasmine.any(String),
        this.loadOrganizationParams,
        null,
        jasmine.objectContaining({ errorMessage: jasmine.any(String) }),
      );
    });

    it('should load Organization', async(function () {
      this.httpResponse = { data: this.organizationReports };

      const _this = this;

      return myPeopleDashboardService
        .loadOrganizations(this.loadOrganizationParams)
        .then(function (loadedOrganization) {
          expect(loadedOrganization).toEqual(_this.organizationReports);
        });
    }));
  });
});
