import 'angular-mocks';

// Constants
var peopleSearchService, $q, $rootScope, httpProxy;

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

describe('peopleSearchService', function() {
    beforeEach(inject(function(
        _peopleSearchService_,
        _$q_,
        _$rootScope_,
        _httpProxy_,
    ) {
        var _this = this;

        peopleSearchService = _peopleSearchService_;
        $q = _$q_;
        $rootScope = _$rootScope_;
        httpProxy = _httpProxy_;

        spyOn(httpProxy, 'get').and.callFake(function() {
            return _this.httpResponse;
        });
    }));

    describe('search', function() {
        it(
            'should make a request for search results',
            asynchronous(function() {
                var _this = this;

                _this.httpResponse = $q.resolve({
                    data: 'results',
                });

                return peopleSearchService
                    .search('query')
                    .then(function(results) {
                        expect(httpProxy.get).toHaveBeenCalledWith(
                            '/people',
                            {
                                'filters[name]': 'query',
                                include:
                                    'organizational_permissions.organization',
                                'fields[organization]': 'name',
                            },
                            { errorMessage: jasmine.any(String) },
                        );
                        expect(results).toEqual('results');
                    });
            }),
        );
    });
});
