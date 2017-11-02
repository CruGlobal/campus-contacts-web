(function () {
    'use strict';

    describe('personHistory component', function () {
        beforeEach(angular.mock.module('missionhubApp'));

        var $ctrl;

        beforeEach(inject(function ($componentController) {
            $ctrl = $componentController(
                'personHistory',
                {
                    $element: null
                },
                {
                    historyFeed: [
                        { id: 1, comment: 'interaction 1' },
                        { id: 2, comment: 'interaction 2' }
                    ]
                }
            );
        }));

        describe('removeInteraction', function () {
            it('should locally remove an interaction from the history feed', function () {
                $ctrl.removeInteraction({ interaction:
                    $ctrl.historyFeed[0]
                });

                expect($ctrl.historyFeed).toEqual([{ id: 2, comment: 'interaction 2' }]);
            });
        });
    });
})();
