(function () {

    'use strict';

    // Constants
    var organizationalPeopleService, httpProxy, $q, $rootScope, JsonApiDataStore, httpResponse;

    function asynchronous (fn) {
        return function (done) {
            var returnValue = fn.call(this, done);
            returnValue.then(function () {
                done();
            }).catch(function (err) {
                done.fail(err);
            });
            $rootScope.$apply();
            return returnValue;
        };
    }

    describe('organizationalPeopleService Tests', function () {

        beforeEach(angular.mock.module('ngAnimate'));
        beforeEach(angular.mock.module('ngMdIcons'));


        beforeEach(angular.mock.module('missionhubApp'));

        beforeEach(inject(function (_organizationalPeopleService_, _httpProxy_, _$q_, _$rootScope_, _JsonApiDataStore_) {

            var _this = this;

            httpProxy = _httpProxy_;
            organizationalPeopleService = _organizationalPeopleService_;
            $q = _$q_;
            $rootScope = _$rootScope_;
            JsonApiDataStore = _JsonApiDataStore_;

            this.interaction = {
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

            this.interaction.included = [{
                type: 'interaction_initiator',
                attributes: {
                    person_id: 20
                }
            }];

            this.updateParams = {
                data: {
                    type: 'person',
                    attributes: {}
                },
                included: [
                    {
                        type: 'organizational_permission',
                        id: 123,
                        attributes: {
                            archive_date: (new Date()).toUTCString()
                        }
                    }
                ]
            };

            spyOn(httpProxy, 'callHttp').and.callFake(function () {
                return _this.httpResponse;
            });

            spyOn(JsonApiDataStore.store, 'sync').and.returnValue(this.httpResponse);

        }));

        describe('organizationalPeople Service', function () {

            it('service should exist', function () {
                expect(organizationalPeopleService).toBeDefined();
            });

        });

        describe('organizationalPeople Service', function () {
            it('should PUT a URL', function () {
                organizationalPeopleService.updatePeople(this.interaction.person_id, this.updateParams);
                expect(httpProxy.callHttp).toHaveBeenCalledWith(
                    'PUT',
                    jasmine.any(String),
                    null,
                    this.updateParams
                );
            });


        });

    });

})();