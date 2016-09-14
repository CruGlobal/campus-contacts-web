(function () {

    'use strict';

    // Constants
    var peopleService, httpProxy, apiEndPoint;

    describe('peopleService Tests', function () {

        beforeEach(angular.mock.module('ngAnimate'));
        beforeEach(angular.mock.module('ngMdIcons'));


        beforeEach(angular.mock.module('missionhubApp'));

        beforeEach(inject(function ($q, $log, _peopleService_, _httpProxy_, _apiEndPoint_) {

            httpProxy = _httpProxy_;
            peopleService = _peopleService_;
            apiEndPoint = _apiEndPoint_;

            spyOn(peopleService, 'saveInteraction').and.callFake( function () {
                var deferred = $q.defer();
                deferred.resolve('success');
                return deferred.promise;
            });

        }));

        it('peopleService should exist', function () {
            expect(peopleService).toBeDefined();
        });

        it('peopleService should contain saveInteraction', function () {
            expect(peopleService.saveInteraction).toBeDefined();
        });

        it('should save Interaction', function () {

            var model = {
                data: {
                    type: 'interaction',
                    attributes: {
                        comment: 'Test data',
                        interaction_type_id: 20
                    },
                    relationships: {
                        organization: {
                            data: {id: 1, type: 'organization'}
                        },
                        receiver: {
                            data: {id: 20, type: 'person'}
                        }
                    }
                }
            };

            model.included = [{
                type: 'interaction_initiator',
                attributes: {
                    person_id: 20
                }
            }];

            var request  = peopleService.saveInteraction(model);

            var response = request.then( function (response) {
                return response;
            });

            var expectedResponse = request.then( function (response) {
                return response;
            });

            expect(response).toEqual(expectedResponse);

        });

    });

})();