let organizationOverviewService, httpProxy, $rootScope, $q;
let peopleScreenService, organizationOverviewTeamService; // eslint-disable-line one-var

function asynchronous(fn) {
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

describe('organizationOverviewService', function () {
  beforeEach(inject(function (
    _organizationOverviewService_,
    _httpProxy_,
    _$rootScope_,
    _$q_,
    _peopleScreenService_,
    _organizationOverviewTeamService_,
  ) {
    organizationOverviewService = _organizationOverviewService_;
    httpProxy = _httpProxy_;
    $rootScope = _$rootScope_;
    $q = _$q_;
    peopleScreenService = _peopleScreenService_;
    organizationOverviewTeamService = _organizationOverviewTeamService_;

    this.id = 123;
    this.placeholderRelation = { _placeHolder: true };
    this.loadedRelation = {};

    spyOn(httpProxy, 'callHttp');
  }));

  describe('loadOrgRelations', function () {
    it('loads groups and surveys when they are unloaded', function () {
      organizationOverviewService.loadOrgRelations({
        _type: 'organization',
        id: this.id,
        groups: [this.placeholderRelation],
        surveys: [this.placeholderRelation],
      });
      expect(httpProxy.callHttp).toHaveBeenCalledWith(
        'GET',
        jasmine.any(String),
        {
          include: 'groups,surveys,surveys.keyword',
          'fields[group]': 'name,location,meets,meeting_day,start_time,end_time,list_publicly,approve_join_requests',
        },
        null,
        jasmine.objectContaining({ errorMessage: jasmine.any(String) }),
      );
    });

    it('loads nothing when groups and surveys are loaded', function () {
      organizationOverviewService.loadOrgRelations({
        _type: 'organization',
        id: this.id,
        groups: [this.loadedRelation],
        surveys: [this.loadedRelation],
      });
      expect(httpProxy.callHttp).not.toHaveBeenCalled();
    });

    it('loads only surveys when groups are loaded', function () {
      organizationOverviewService.loadOrgRelations({
        _type: 'organization',
        id: this.id,
        groups: [this.loadedRelation],
        surveys: [this.placeholderRelation],
      });
      expect(httpProxy.callHttp).toHaveBeenCalledWith(
        'GET',
        jasmine.any(String),
        {
          include: 'surveys,surveys.keyword',
          'fields[group]': 'name,location,meets,meeting_day,start_time,end_time,list_publicly,approve_join_requests',
        },
        null,
        jasmine.objectContaining({ errorMessage: jasmine.any(String) }),
      );
    });

    it('loads only groups when groups are partialy loaded and surveys are loaded', function () {
      organizationOverviewService.loadOrgRelations({
        _type: 'organization',
        id: this.id,
        groups: [this.loadedRelation, this.placeholderRelation],
        surveys: [this.loadedRelation],
      });
      expect(httpProxy.callHttp).toHaveBeenCalledWith(
        'GET',
        jasmine.any(String),
        {
          include: 'groups',
          'fields[group]': 'name,location,meets,meeting_day,start_time,end_time,list_publicly,approve_join_requests',
        },
        null,
        jasmine.objectContaining({ errorMessage: jasmine.any(String) }),
      );
    });
  });

  describe('getPersonCount', function () {
    it(
      'should load the person count',
      asynchronous(function () {
        spyOn(peopleScreenService, 'loadOrgPeopleCount').and.returnValue($q.resolve(5));

        return organizationOverviewService.getPersonCount({ id: 1 }).then(function (personCount) {
          expect(peopleScreenService.loadOrgPeopleCount).toHaveBeenCalledWith(1);
          expect(personCount).toBe(5);
        });
      }),
    );
  });

  describe('getTeamCount', function () {
    it(
      'should load the team count',
      asynchronous(function () {
        spyOn(organizationOverviewTeamService, 'loadOrgTeamCount').and.returnValue($q.resolve(5));

        return organizationOverviewService.getTeamCount({ id: 1 }).then(function (personCount) {
          expect(organizationOverviewTeamService.loadOrgTeamCount).toHaveBeenCalledWith(1);
          expect(personCount).toBe(5);
        });
      }),
    );
  });
});
