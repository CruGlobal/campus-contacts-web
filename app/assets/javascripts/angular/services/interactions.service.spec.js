(function () {
    'use strict';

    // Constants
    var $q, $rootScope, interactionsService, httpProxy, JsonApiDataStore;

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

    describe('interactionsService', function () {
        beforeEach(angular.mock.module('missionhubApp'));

        beforeEach(inject(function (_$q_, _$rootScope_, _interactionsService_,
                                    _httpProxy_, _JsonApiDataStore_) {
            var _this = this;

            $q = _$q_;
            $rootScope = _$rootScope_;
            interactionsService = _interactionsService_;
            httpProxy = _httpProxy_;
            JsonApiDataStore = _JsonApiDataStore_;

            this.interaction = new JsonApiDataStore.Model('interaction');
            this.interaction.setAttribute('id', 1);
            this.interaction.setAttribute('comment', 'Test Interaction');

            this.httpResponse = this.interaction.serialize();
            spyOn(httpProxy, 'put').and.callFake(function () {
                return $q.resolve(_this.httpResponse);
            });
            spyOn(httpProxy, 'delete').and.callFake(function () {
                return $q.resolve(_this.httpResponse);
            });
        }));

        describe('updateInteraction', function () {
            it('should save interaction changes to the server', async(function () {
                var _this = this;

                return interactionsService.updateInteraction(this.interaction).then(function (savedInteraction) {
                    expect(httpProxy.put).toHaveBeenCalledWith(
                        jasmine.any(String),
                        _this.interaction.serialize(),
                        jasmine.objectContaining({ errorMessage: jasmine.any(String) })
                    );

                    expect(savedInteraction).toEqual(_this.httpResponse.data);
                });
            }));
        });

        describe('deleteInteraction', function () {
            it('should delete interactions from the server', async(function () {
                var _this = this;

                return interactionsService.deleteInteraction(this.interaction).then(function () {
                    expect(httpProxy.delete).toHaveBeenCalledWith(
                        jasmine.any(String),
                        _this.interaction.serialize(),
                        jasmine.objectContaining({ errorMessage: jasmine.any(String) })
                    );
                });
            }));
        });
    });
})();
