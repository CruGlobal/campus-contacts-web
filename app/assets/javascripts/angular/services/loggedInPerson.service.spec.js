// import '../testSetup.spec';

import angular from 'angular';

import './loggedInPerson.service';

// Constants
var loggedInPerson, $q, $rootScope, httpProxy, JsonApiDataStore;

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

describe('loggedInPerson service', function() {
    beforeEach(inject(function(
        _loggedInPerson_,
        _$q_,
        _$rootScope_,
        _httpProxy_,
        _JsonApiDataStore_,
    ) {
        var _this = this;

        loggedInPerson = _loggedInPerson_;
        $q = _$q_;
        $rootScope = _$rootScope_;
        httpProxy = _httpProxy_;
        JsonApiDataStore = _JsonApiDataStore_;

        this.person = {
            id: 123,
            name: 'John Doe',
        };

        // Can be changed in individual tests
        this.httpResponse = $q.resolve({
            data: this.person,
        });
        jest.spyOn(httpProxy, 'callHttp').mockImplementation(function() {
            return _this.httpResponse;
        });

        jest.spyOn(JsonApiDataStore.store, 'find').mockReturnValue(this.person);
    }));

    describe('loggedInPerson.load', function() {
        it('should GET a URL', function() {
            loggedInPerson.load();
            expect(httpProxy.callHttp).toHaveBeenCalledWith(
                'GET',
                jasmine.any(String),
                { include: jasmine.any(String) },
                null,
                jasmine.objectContaining({ errorMessage: jasmine.any(String) }),
            );
        });

        it(
            'should return a promise',
            asynchronous(function() {
                var _this = this;
                return loggedInPerson.load().then(function(loadedPerson) {
                    expect(loadedPerson).toBe(_this.person);
                });
            }),
        );
    });

    describe('loggedInPerson.person', function() {
        it('should initially be null', function() {
            expect(loggedInPerson.person).toBe(null);
        });

        it(
            'should eventually be a person',
            asynchronous(function() {
                var _this = this;
                return loggedInPerson.load().then(function() {
                    expect(loggedInPerson.person).toBe(_this.person);
                });
            }),
        );

        it(
            'should still be null after an error',
            asynchronous(function() {
                this.httpResponse = $q.reject(new Error());
                return loggedInPerson.load().catch(function() {
                    expect(loggedInPerson.person).toBe(null);
                });
            }),
        );

        it('should not be settable', function() {
            expect(function() {
                loggedInPerson.person = this.person;
            }).toThrow();
        });
    });

    describe('loggedInPerson.loadingPromise', function() {
        it('should be the return value of loggedInPerson.load()', function() {
            var loadingPromise = loggedInPerson.load();
            expect(loggedInPerson.loadingPromise).toBe(loadingPromise);
        });
    });
});
