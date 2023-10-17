import 'angular-mocks';

// Constants
let $controller, $scope;

describe('peopleFiltersPanel Components Tests', function () {
  beforeEach(inject(function ($rootScope, $componentController) {
    $scope = $rootScope.$new();

    $controller = $componentController('peopleFiltersPanel', { $scope }, { myBinding: { period: '<', editMode: '<' } });
  }));

  describe('Components.Controller', function () {
    it('should exist', function () {
      expect($controller).toBeDefined();
    });

    it('should hideNonFilterableQuestionAnswerResponse return true', function () {
      expect(
        $controller.hideNonFilterableQuestionAnswerResponse({
          kind: 'TextField',
          label: 'last name',
        }),
      ).toEqual(true);

      expect(
        $controller.hideNonFilterableQuestionAnswerResponse({
          kind: 'CheckboxField',
          label: 'last name',
        }),
      ).toEqual(false);
    });
  });
});
