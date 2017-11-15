import 'angular-mocks';

// Constants
var ProgressiveListLoader, $rootScope, $q, httpProxy, _;

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

describe('ProgressiveListLoader', function () {
    beforeEach(angular.mock.module('missionhubApp'));

    beforeEach(inject(function (_ProgressiveListLoader_, _$rootScope_, _$q_, _httpProxy_, ___) {
        ProgressiveListLoader = _ProgressiveListLoader_;
        $rootScope = _$rootScope_;
        $q = _$q_;
        httpProxy = _httpProxy_;
        _ = ___;

        this.listLoader = new ProgressiveListLoader({ modelType: 'person' });

        var _this = this;
        spyOn(httpProxy, 'callHttp').and.callFake(function () {
            return $q.resolve({
                data: _this.responsePeople,
                meta: { total: _this.responseTotal }
            });
        });
    }));

    describe('loadMore', function () {
        it('loads first batch of people', asynchronous(function () {
            this.responsePeople = [
                { id: 1 },
                { id: 2 },
                { id: 3 }
            ];
            this.responseTotal = 4;

            return this.listLoader.loadMore({ include: 'phone_numbers' })
                .then(function (resp) {
                    var respIds = _.map(resp.list, 'id');
                    expect(respIds).toEqual([1, 2, 3]);
                    expect(resp.loadedAll).toBe(false);

                    expect(httpProxy.callHttp)
                        .toHaveBeenCalledWith('GET',
                                              jasmine.any(String),
                                              jasmine.objectContaining({ 'page[limit]': 26, 'page[offset]': 0 }),
                                              null,
                                              jasmine.any(Object));
                });
        }));

        it('loads second batch with more to come', asynchronous(function () {
            // put some in the list
            this.listLoader.reset([
                { id: 1 },
                { id: 2 },
                { id: 3 }
            ]);

            this.responsePeople = [
                { id: 3 },
                { id: 4 },
                { id: 5 },
                { id: 6 }
            ];
            this.responseTotal = 7;

            return this.listLoader.loadMore()
                .then(function (resp) {
                    var respIds = _.map(resp.list, 'id');
                    expect(respIds).toEqual([1, 2, 3, 4, 5, 6]);
                    expect(resp.loadedAll).toBe(false);

                    expect(httpProxy.callHttp)
                        .toHaveBeenCalledWith('GET',
                                              jasmine.any(String),
                                              jasmine.objectContaining({ 'page[limit]': 26, 'page[offset]': 2 }),
                                              null,
                                              jasmine.any(Object));
                });
        }));

        it('loads second and final batch', asynchronous(function () {
            this.listLoader.reset([
                { id: 1 },
                { id: 2 }
            ]);

            this.responsePeople = [
                { id: 2 },
                { id: 3 }
            ];
            this.responseTotal = 3;

            return this.listLoader.loadMore()
                .then(function (resp) {
                    var respIds = _.map(resp.list, 'id');
                    expect(respIds).toEqual([1, 2, 3]);
                    expect(resp.loadedAll).toBe(true);

                    expect(httpProxy.callHttp)
                        .toHaveBeenCalledWith('GET',
                                              jasmine.any(String),
                                              jasmine.objectContaining({ 'page[limit]': 26, 'page[offset]': 1 }),
                                              null,
                                              jasmine.any(Object));
                });
        }));
    });
});
