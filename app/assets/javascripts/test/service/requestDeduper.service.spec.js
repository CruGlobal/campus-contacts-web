(function () {
    'use strict';

    // Constants
    var RequestDeduper, $rootScope, $q;

    // Add better asynchronous support to a test function
    // The test function must return a promise
    // The promise will automatically be bound to "done" and the $rootScope will be automatically digested
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

    describe('RequestDeduper', function () {
        beforeEach(angular.mock.module('missionhubApp'));

        beforeEach(inject(function (_RequestDeduper_, _$rootScope_, _$q_) {
            RequestDeduper = _RequestDeduper_;
            $rootScope = _$rootScope_;
            $q = _$q_;

            this.requestDeduper = new RequestDeduper();
        }));

        describe('request', function () {
            function makeSuccessfulRequest () {
                return $q.resolve();
            }

            it('should call makeRequest with a timeout promise', function () {
                var makeRequest = jasmine.createSpy().and.returnValue($q.resolve());
                this.requestDeduper.request(makeRequest);
                expect(makeRequest).toHaveBeenCalledWith({ timeout: jasmine.any(Object) });

                var timeoutPromise = makeRequest.calls.argsFor(0)[0].timeout;
                expect(timeoutPromise.then).toEqual(jasmine.any(Function));
            });

            it('should resolve the timeout promise when making the second request', function () {
                var unresolvedPromise = $q(function () {});
                var makeRequest = jasmine.createSpy().and.returnValue(unresolvedPromise);

                // Make the first request
                this.requestDeduper.request(makeRequest);

                // Save off the first request's timeout promise
                var timeoutPromise = makeRequest.calls.argsFor(0)[0].timeout;

                // Make the second request
                this.requestDeduper.request(makeSuccessfulRequest);

                // Check whether timeoutPromise is resolved
                var resolved = false;
                timeoutPromise.then(function () {
                    resolved = true;
                });
                $rootScope.$digest();

                // Expect the timeout promise from the first request to be resolved
                expect(resolved).toBe(true);
            });

            it('should flag cancelation errors', asynchronous(function () {
                // Make the first request
                var firstRequestCompletion = $q.defer();
                var firstRequest = this.requestDeduper.request(function () {
                    return firstRequestCompletion.promise;
                });

                // Make the second request
                this.requestDeduper.request(makeSuccessfulRequest);

                // First request completes
                firstRequestCompletion.resolve();

                return firstRequest.catch(function (err) {
                    expect(err.canceled).toBe(true);
                });
            }));

            it('should not flag non-cancelation errors', asynchronous(function () {
                // Make the first request and fail it
                var firstRequestCompletion = $q.defer();
                var firstRequest = this.requestDeduper.request(makeSuccessfulRequest);
                firstRequestCompletion.reject(new Error());

                // Make the second request
                this.requestDeduper.request(makeSuccessfulRequest);

                return firstRequest.catch(function (err) {
                    expect(err.canceled).toBe(false);
                });
            }));
        });
    });
})();
