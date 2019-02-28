import 'angular-mocks';

// Constants
var errorService, $q, $rootScope, _;

// Add better asynchronous support to a test function
// The test function must return a promise
// The promise will automatically be bound to "done" and the $rootScope will be automatically digested
function asynchronous(fn) {
    return function(done) {
        var returnValue = fn.call(this, done);
        returnValue
            .then(function() {
                done();
            })
            .catch(function(err) {
                done.fail(err);
            });
        $rootScope.$apply();
        return returnValue;
    };
}

describe('errorService', function() {
    beforeEach(function() {
        angular.mock.module(function($provide) {
            // Mock $timeout so that it always returns a resolved promise
            $provide.factory('$timeout', function($q) {
                return function() {
                    return $q.resolve();
                };
            });
        });
    });

    beforeEach(inject(function(_errorService_, _$q_, _$rootScope_, ___) {
        errorService = _errorService_;
        $q = _$q_;
        $rootScope = _$rootScope_;
        _ = ___;
    }));

    describe('autoRetry', function() {
        it(
            'does nothing when the promise resolves',
            asynchronous(function() {
                var result = 123;
                var getPromise = jest.fn().and.returnValue($q.resolve(result));
                var decorated = errorService.autoRetry(getPromise);
                return decorated('arg1', 'arg2', 'arg3').then(function(value) {
                    expect(value).toBe(result);
                    expect(getPromise).toHaveBeenCalledTimes(1);
                    expect(getPromise).toHaveBeenCalledWith(
                        'arg1',
                        'arg2',
                        'arg3',
                    );
                });
            }),
        );

        it(
            'retries and eventually resolves when the promise rejects once',
            asynchronous(function() {
                var result = 123;
                var getPromise = jest
                    .fn()
                    .and.returnValues($q.reject(), $q.resolve(result));
                var decorated = errorService.autoRetry(getPromise, {
                    retryCount: 3,
                });
                return decorated().then(function(value) {
                    expect(value).toBe(result);
                    expect(getPromise).toHaveBeenCalledTimes(2);
                });
            }),
        );

        it(
            'retries and eventually rejects when the promise always rejects',
            asynchronous(function() {
                var error = new Error();
                var getPromise = jest.fn().and.returnValue($q.reject(error));
                var decorated = errorService.autoRetry(getPromise, {
                    retryCount: 3,
                });
                jest.spyOn(errorService, 'displayError').mockImplementation(
                    function(err) {
                        return $q.reject(err);
                    },
                );
                return decorated().catch(function(value) {
                    expect(value).toBe(error);
                    expect(getPromise).toHaveBeenCalledTimes(4);
                    expect(errorService.displayError).toHaveBeenCalledWith(
                        error,
                        true,
                    );
                });
            }),
        );

        it(
            'does not retry errors that do not match the filter',
            asynchronous(function() {
                var error = new Error();
                var result = 123;
                var getPromise = jest
                    .fn()
                    .and.returnValues($q.reject(error), $q.resolve(result));
                var decorated = errorService.autoRetry(getPromise, {
                    retryCount: 3,
                    retryFilter: _.constant(false),
                });
                return decorated().catch(function(err) {
                    expect(err).toBe(error);
                    expect(getPromise).toHaveBeenCalledTimes(1);
                });
            }),
        );

        it(
            'ignores errors that match the criteria',
            asynchronous(function() {
                var error = new Error();
                var getPromise = jest.fn().and.returnValue($q.reject(error));
                var decorated = errorService.autoRetry(getPromise, {
                    retryCount: 3,
                    ignoreFilter: _.constant(true),
                });
                return decorated().catch(function(err) {
                    expect(err).toBe(error);
                    expect(getPromise).toHaveBeenCalledTimes(1);
                });
            }),
        );
    });
});
