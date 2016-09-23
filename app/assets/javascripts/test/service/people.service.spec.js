(function () {

    'use strict';

    // Constants
    var peopleService, httpProxy, $q, $rootScope;

     function async (fn) {
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

    describe('People Service Tests', function () {

        beforeEach(angular.mock.module('missionhubApp'));



        beforeEach(inject(function (_peopleService_, _$q_, _$rootScope_, _httpProxy_) {

            var _this = this;

            peopleService = _peopleService_;
            $q = _$q_;
            $rootScope = _$rootScope_;
            httpProxy = _httpProxy_;

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

            this.newInteraction = { interaction_type_id: 123 };

            this.httpResponse = $q.resolve(
                this.newInteraction
            );


            spyOn(httpProxy, 'callHttp').and.callFake(function () {
                return _this.httpResponse;
            });

        }));

        describe('Save interaction', function(){
            it('should POST a Url', function(){
                peopleService.saveInteraction(this.interaction);
                expect(httpProxy.callHttp).toHaveBeenCalledWith(
                    'POST',
                    jasmine.any(String),
                    null,
                    this.interaction
                )
            });

            it('should return a promise', async(function () {
                var _this = this;
                return peopleService.saveInteraction(_this.interaction).then(function (newInteraction) {
                    expect(newInteraction).toEqual(_this.newInteraction);
                });
            }));

        });

        describe('People service', function(){
            it('should be defined', function () {
                expect(peopleService).toBeDefined();
            });

        });

    });

})();