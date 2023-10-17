import 'angular-mocks';

// Constants
let $controller, myPeopleDashboardService, $scope, loggedInPerson;

describe('myPeopleDashboard Components Tests', function () {
  beforeEach(inject(function ($rootScope, $componentController, _loggedInPerson_) {
    $scope = $rootScope.$new();
    loggedInPerson = _loggedInPerson_;

    $controller = $componentController(
      'myPeopleDashboard',
      { $scope },
      { myBinding: { period: '<', editMode: '<' } },
      loggedInPerson,
    );
    myPeopleDashboardService = jasmine.createSpyObj('myPeopleDashboardService', ['loadPeople', 'loadReports']);
  }));

  describe('Components.Controller', function () {
    it('should exist', function () {
      expect($controller).toBeDefined();
    });

    it('loadPeople should have been called', function () {
      myPeopleDashboardService.loadPeople();
      expect(myPeopleDashboardService.loadPeople).toHaveBeenCalled();
    });
  });

  describe('People Tests', function () {
    it('should contain loadPeople', function () {
      expect(myPeopleDashboardService.loadPeople).toBeDefined();
    });
  });
});
