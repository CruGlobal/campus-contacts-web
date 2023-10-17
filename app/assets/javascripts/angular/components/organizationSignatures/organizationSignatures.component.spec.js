import 'angular-mocks';

// Constants
let $controller, $scope;

describe('organizationSignatures Components Tests', function () {
  beforeEach(inject(function ($rootScope, $componentController) {
    $scope = $rootScope.$new();

    $controller = $componentController('organizationSignatures', { $scope }, { myBinding: { orgId: '<' } });
  }));

  describe('Components.Controller', function () {
    it('should exist', function () {
      expect($controller).toBeDefined();
    });

    it('should set tableState', function () {
      const tableState = {
        pagination: {
          start: 0,
          currentPage: 0,
          numberOfPages: 2,
          pages: [0, 1, 2],
          totalItemCount: 50,
        },
      };
      $controller.load(tableState);

      expect($controller.tableState).toEqual(tableState);
      expect($controller.isLoading).toBeTrue();
    });

    it('should set pagination start', function () {
      $controller.tableState = {
        pagination: {
          start: 0,
          currentPage: 0,
          numberOfPages: 2,
          pages: [0, 1, 2],
          totalItemCount: 50,
        },
      };
      $controller.setPage(10, 'test Search');
      expect($controller.tableState.pagination.start).toEqual(500);
    });
  });
});
