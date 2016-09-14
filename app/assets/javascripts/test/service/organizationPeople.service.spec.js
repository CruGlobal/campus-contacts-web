(function () {

    'use strict';

    // Constants
    var organizationalPeopleService, httpProxy, apiEndPoint;

    describe('organizationalPeopleService Tests', function () {

        beforeEach(angular.mock.module('ngAnimate'));
        beforeEach(angular.mock.module('ngMdIcons'));


        beforeEach(angular.mock.module('missionhubApp'));

        beforeEach(inject(function ($q, $log, _organizationalPeopleService_, _httpProxy_, _apiEndPoint_) {

            httpProxy = _httpProxy_;
            organizationalPeopleService = _organizationalPeopleService_;
            apiEndPoint = _apiEndPoint_;

            spyOn(organizationalPeopleService, 'updatePeople').and.callFake( function () {
                var deferred = $q.defer();
                deferred.resolve('success');
                return deferred.promise;
            });

            spyOn(organizationalPeopleService, 'saveAnonymousInteraction').and.callFake( function () {
                var deferred = $q.defer();
                deferred.resolve('success');
                return deferred.promise;
            });

        }));

        it('organizationalPeopleService should exist', function () {
            expect(organizationalPeopleService).toBeDefined();
        });

        it('organizationalPeopleService should contain updatePeople', function () {
            expect(organizationalPeopleService.updatePeople).toBeDefined();
        });

        it('organizationalPeopleService should contain saveAnonymousInteraction', function () {
            expect(organizationalPeopleService.saveAnonymousInteraction).toBeDefined();
        });

        it('should save updatePeople', function () {

            var model = {
                data: {
                    type: 'person',
                    attributes: {}
                },
                included: [
                    {
                        type: 'organizational_permission',
                        id: 1,
                        attributes: {
                            archive_date: (new Date()).toUTCString()
                        }
                    }
                ]
            };

            model.personId = 20;

            var request  = organizationalPeopleService.updatePeople(model.personId, model);

            var response = request.then( function (response) {
                return response;
            });

            var expectedResponse = request.then( function (response) {
                return response;
            });

            expect(response).toEqual(expectedResponse);

        });

        it('should save saveAnonymousInteraction', function () {

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

            var request  = organizationalPeopleService.saveAnonymousInteraction(model);

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