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
                personTab: {
                    person: {
                        interactions: [
                            {
                                id: 1,
                                comment: 'interaction 1',
                                _type: 'interaction',
                                organization: {
                                    id: 1
                                }
                            },
                            {
                                id: 2,
                                comment: 'interaction 2',
                                _type: 'interaction',
                                organization: {
                                    id: 1
                                }
                            }
                        ]
                    },
                    organizationId: 1

                }
            }
        );
    }));

    describe('removeInteraction', function () {
        it('should locally remove an interaction from the history feed', function () {
            $ctrl.removeInteraction({ interaction:
                $ctrl.personTab.person.interactions[0]
            });

            expect($ctrl.historyFeed).toEqual([{
                id: 2,
                comment: 'interaction 2',
                _type: 'interaction',
                organization: {
                    id: 1
                }
            }]);
        });
    });
});
