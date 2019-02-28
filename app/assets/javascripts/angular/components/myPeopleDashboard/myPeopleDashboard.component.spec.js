import 'angular-mocks';

// Constants
var $controller, myPeopleDashboardService, $scope, loggedInPerson;

describe('myPeopleDashboard Components Tests', function() {
    beforeEach(inject(function(
        $rootScope,
        $componentController,
        _loggedInPerson_,
    ) {
        $scope = $rootScope.$new();
        loggedInPerson = _loggedInPerson_;

        jest.spyOn(loggedInPerson, 'person').mockReturnValue({
            first_name: 'John',
        });

        $controller = $componentController(
            'myPeopleDashboard',
            { $scope: $scope },
            { myBinding: { period: '<', editMode: '<' } },
            loggedInPerson,
        );

        myPeopleDashboardService = jasmine.createSpyObj(
            'myPeopleDashboardService',
            ['loadPeople', 'loadReports', 'loadOrganizations'],
        );

        describe('Components.Controller', function() {
            it('should exist', function() {
                expect($controller).toBeDefined();
            });

            it('loadPeople should have been called', function() {
                myPeopleDashboardService.loadPeople();
                expect(myPeopleDashboardService.loadPeople).toHaveBeenCalled();
            });
        });
    }));
});
