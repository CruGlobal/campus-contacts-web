describe('organizationOverviewTeam component', function() {
  beforeEach(angular.mock.module('missionhubApp'));

  var $ctrl,
    $q,
    $rootScope,
    organizationOverviewTeamService,
    reportsService,
    periodService;

  beforeEach(inject(function(
    $componentController,
    _$q_,
    _$timeout_,
    _$rootScope_,
  ) {
    organizationOverviewTeamService = jasmine.createSpyObj(
      'organizationOverviewTeamService',
      ['loadOrgTeam'],
    );
    reportsService = jasmine.createSpyObj('reportsService', [
      'loadMultiplePeopleReports',
    ]);
    periodService = jasmine.createSpyObj('periodService', ['subscribe']);

    $ctrl = $componentController(
      'organizationOverviewTeam',
      {
        organizationOverviewTeamService: organizationOverviewTeamService,
        reportsService: reportsService,
        periodService: periodService,
      },
      {
        organizationOverview: {
          org: {
            id: 1,
          },
        },
      },
    );
    $q = _$q_;
    $rootScope = _$rootScope_;
  }));

  describe('$onInit', function() {
    it('should reload the team reports when the period changes', function() {
      $ctrl.$onInit();

      expect(periodService.subscribe).toHaveBeenCalledWith(
        jasmine.any(Object),
        jasmine.any(Function),
      );
      expect(reportsService.loadMultiplePeopleReports).not.toHaveBeenCalled();

      $ctrl.team = 'fake team';

      periodService.subscribe.calls.argsFor(0)[1]();

      expect(reportsService.loadMultiplePeopleReports).toHaveBeenCalledWith(
        [1],
        'fake team',
      );
    });
  });

  describe('loadTeamPage', function() {
    it('should load the people on the team', function() {
      organizationOverviewTeamService.loadOrgTeam.and.returnValue(
        $q.resolve({
          list: 'teamList',
          loadedAll: true,
        }),
      );
      $ctrl.loadTeamPage();
      expect(organizationOverviewTeamService.loadOrgTeam).toHaveBeenCalledWith(
        { id: 1 },
        jasmine.any(Object),
      );
      $rootScope.$digest();
      expect($ctrl.team).toEqual('teamList');
      expect(reportsService.loadMultiplePeopleReports).toHaveBeenCalledWith(
        [1],
        'teamList',
      );
      expect($ctrl.loadedAll).toEqual(true);
      expect($ctrl.busy).toEqual(false);
    });
  });
});
