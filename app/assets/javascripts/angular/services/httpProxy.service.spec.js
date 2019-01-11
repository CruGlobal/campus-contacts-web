import 'angular-mocks';

// Constants
var httpProxy, $rootScope, $http, $q, JsonApiDataStore, RequestDeduper;

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

describe('HttpProxyService Tests', function() {
    beforeEach(function() {
        var _this = this;
        this.token = null;
        this.responseData = {};
        this.responseHeaders = {
            get 'x-mh-session'() {
                return _this.token;
            },
        };
        this.httpResponse = {
            headers: function(header) {
                return _this.responseHeaders[header];
            },
            get data() {
                return _this.responseData;
            },
        };

        // Mock out the $http service
        angular.mock.module(function($provide) {
            $provide.factory('$http', function($q) {
                var $http = jasmine
                    .createSpy('$http')
                    .and.returnValue($q.resolve(_this.httpResponse));
                $http.defaults = { headers: { common: {} } };
                $http.get = jasmine.createSpy('$http.get');
                return $http;
            });
        });
    });

    beforeEach(inject(function(
        _httpProxy_,
        _$rootScope_,
        _$http_,
        _$q_,
        _JsonApiDataStore_,
        _RequestDeduper_,
    ) {
        httpProxy = _httpProxy_;
        $rootScope = _$rootScope_;
        $http = _$http_;
        $q = _$q_;
        JsonApiDataStore = _JsonApiDataStore_;
        RequestDeduper = _RequestDeduper_;
    }));

    describe('callHttp', function() {
        beforeEach(inject(function(envService) {
            this.apiUrl = 'http://localhost:4000';
            this.method = 'GET';
            this.url = '/';
            this.params = { key1: 'value1' };
            this.data = { key2: 'value2' };
            this.config = { key3: 'value3', errorMessage: 'error' };

            spyOn(envService, 'read').and.returnValue(this.apiUrl);
        }));

        it('should get the base API url from envService', inject(function(
            envService,
        ) {
            httpProxy.callHttp(this.method, this.url, this.params, this.data);
            expect(envService.read).toHaveBeenCalledWith('apiUrl');

            var httpConfig = $http.calls.argsFor(0)[0];
            expect(httpConfig.url.indexOf(this.apiUrl)).toBe(0);
        }));

        it('should call $http', function() {
            httpProxy.callHttp(
                this.method,
                this.url,
                this.params,
                this.data,
                this.config,
            );
            expect($http).toHaveBeenCalledWith({
                method: this.method,
                url: this.apiUrl + this.url,
                data: this.data,
                params: this.params,
                key3: 'value3',
                errorMessage: 'error',
            });
        });

        it(
            'should set the Authorization header when a token is received',
            asynchronous(function() {
                var _this = this;
                this.token = 'abcde';
                this.responseData = { data: [] };
                spyOn(this.httpResponse, 'headers').and.callThrough();
                return httpProxy
                    .callHttp(this.method, this.url, this.params, this.data)
                    .then(function() {
                        expect(_this.httpResponse.headers).toHaveBeenCalledWith(
                            'x-mh-session',
                        );
                        expect(
                            $http.defaults.headers.common.Authorization,
                        ).toBe('Bearer ' + _this.token);
                    });
            }),
        );

        it(
            'should not set the Authorization header when a token is not received',
            asynchronous(function() {
                var originalAuthorization = 'Bearer old';
                this.token = null;
                $http.defaults.headers.common.Authorization = originalAuthorization;
                return httpProxy
                    .callHttp(this.method, this.url, this.params, this.data)
                    .then(function() {
                        expect(
                            $http.defaults.headers.common.Authorization,
                        ).toBe(originalAuthorization);
                    });
            }),
        );

        it(
            'should sync the JSON store with the response',
            asynchronous(function() {
                var _this = this;
                spyOn(JsonApiDataStore.store, 'syncWithMeta');
                return httpProxy
                    .callHttp(this.method, this.url, this.params, this.data)
                    .then(function() {
                        expect(
                            JsonApiDataStore.store.syncWithMeta,
                        ).toHaveBeenCalledWith(_this.responseData);
                    });
            }),
        );

        it(
            'should use the deduper instance when provided',
            asynchronous(function() {
                var deduper = new RequestDeduper();
                spyOn(deduper, 'request').and.returnValue($q.resolve());
                var config = {
                    deduper: deduper,
                };

                return httpProxy
                    .callHttp(
                        this.method,
                        this.url,
                        this.params,
                        this.data,
                        config,
                    )
                    .then(function() {
                        expect(deduper.request).toHaveBeenCalledWith(
                            jasmine.any(Function),
                        );
                    });
            }),
        );

        describe('aliases', function() {
            beforeEach(function() {
                spyOn(httpProxy, 'callHttp');
            });

            it('should contain get', function() {
                httpProxy.get(this.url, this.params, this.config);
                expect(httpProxy.callHttp).toHaveBeenCalledWith(
                    'GET',
                    this.url,
                    this.params,
                    null,
                    this.config,
                );
            });

            it('should contain post', function() {
                httpProxy.post(this.url, this.data, this.config);
                expect(httpProxy.callHttp).toHaveBeenCalledWith(
                    'POST',
                    this.url,
                    null,
                    this.data,
                    this.config,
                );
            });

            it('should contain put', function() {
                httpProxy.put(this.url, this.data, this.config);
                expect(httpProxy.callHttp).toHaveBeenCalledWith(
                    'PUT',
                    this.url,
                    null,
                    this.data,
                    this.config,
                );
            });

            it('should contain delete', function() {
                httpProxy.delete(this.url, this.params, this.config);
                expect(httpProxy.callHttp).toHaveBeenCalledWith(
                    'DELETE',
                    this.url,
                    this.params,
                    null,
                    this.config,
                );
            });
        });
    });

    describe('model loading', function() {
        beforeEach(function() {
            this.loadedModel = {};
            this.placeholderModel = { _placeHolder: true };
        });

        describe('isLoaded', function() {
            it('should treat null models as unloaded', function() {
                expect(httpProxy.isLoaded(null)).toBe(false);
            });

            it('should treat a placeholder model as unloaded', function() {
                expect(httpProxy.isLoaded(this.placeholderModel)).toBe(false);
            });

            it('should treat a model as loaded', function() {
                expect(httpProxy.isLoaded(this.loadedModel)).toBe(true);
            });
        });

        describe('getUnloadedRelationships', function() {
            it('should treat all relationships as unloaded when the model is null', function() {
                this.relationships = ['a', 'b', 'c'];
                expect(
                    httpProxy.getUnloadedRelationships(
                        null,
                        this.relationships,
                    ),
                ).toEqual(this.relationships);
            });

            it('should treat all relationships as unloaded when the model is a placeholder', function() {
                this.relationships = ['a', 'b', 'c'];
                expect(
                    httpProxy.getUnloadedRelationships(
                        this.placeholderModel,
                        this.relationships,
                    ),
                ).toEqual(this.relationships);
            });

            it('should correctly detect unloaded relationships', function() {
                this.model = {
                    // a is undefined
                    b: [],
                    c: [this.loadedModel],
                    d: [this.placeholderModel],
                    e: [this.loadedModel, this.placeholderModel],
                    f: [{ a: this.loadedModel }],
                    g: [{ a: this.placeholderModel }],
                    h: [{ a: this.loadedModel }, { a: this.placeholderModel }],
                    i: [{ a: { b: { c: this.loadedModel } } }],
                    j: [{ a: { b: { c: this.placeholderModel } } }],
                    k: [{ a: this.placeholderModel }],
                };
                this.relationships = [
                    'a',
                    'b',
                    'c',
                    'd',
                    'e',
                    'f.a',
                    'g.a',
                    'h.a',
                    'i.a.b.c',
                    'j.a.b.c',
                    'k.a.b.c',
                ];
                expect(
                    httpProxy.getUnloadedRelationships(
                        this.model,
                        this.relationships,
                    ),
                ).toEqual(['a', 'd', 'e', 'g.a', 'h.a', 'j.a.b.c', 'k.a.b.c']);
            });
        });

        describe('getModel', function() {
            beforeEach(function() {
                this.url = '/';
                this.type = 'abc';
                this.id = 123;
                this.model = { id: this.id };
                this.relationships = ['a', 'b', 'c'];
                this.config = { key: 'value' };

                spyOn(httpProxy, 'callHttp');
            });

            it(
                'should not make a network request when the model is already loaded',
                asynchronous(function() {
                    spyOn(JsonApiDataStore.store, 'find').and.returnValues(
                        this.model,
                        this.model,
                    );
                    spyOn(
                        httpProxy,
                        'getUnloadedRelationships',
                    ).and.returnValue([]);

                    var _this = this;
                    return httpProxy
                        .getModel(
                            this.url,
                            this.type,
                            this.id,
                            this.relationships,
                        )
                        .then(function(model) {
                            expect(model).toBe(_this.model);
                            expect(httpProxy.callHttp).not.toHaveBeenCalled();
                        });
                }),
            );

            it(
                'should make a network request when the model is not already loaded',
                asynchronous(function() {
                    spyOn(JsonApiDataStore.store, 'find').and.returnValues(
                        null,
                        this.model,
                    );
                    spyOn(
                        httpProxy,
                        'getUnloadedRelationships',
                    ).and.returnValue([]);

                    var _this = this;
                    return httpProxy
                        .getModel(
                            this.url,
                            this.type,
                            this.id,
                            this.relationships,
                            this.config,
                        )
                        .then(function(model) {
                            expect(model).toBe(_this.model);
                            expect(httpProxy.callHttp).toHaveBeenCalledWith(
                                'GET',
                                _this.url,
                                {
                                    include: '',
                                },
                                null,
                                _this.config,
                            );
                        });
                }),
            );

            it(
                'should make a network request when the model relationships are not already loaded',
                asynchronous(function() {
                    spyOn(JsonApiDataStore.store, 'find').and.returnValues(
                        this.model,
                        this.model,
                    );
                    spyOn(
                        httpProxy,
                        'getUnloadedRelationships',
                    ).and.returnValue(this.relationships);

                    var _this = this;
                    return httpProxy
                        .getModel(
                            this.url,
                            this.type,
                            this.id,
                            this.relationships,
                            this.config,
                        )
                        .then(function(model) {
                            expect(model).toBe(_this.model);
                            expect(httpProxy.callHttp).toHaveBeenCalledWith(
                                'GET',
                                _this.url,
                                {
                                    include: 'a,b,c',
                                },
                                null,
                                _this.config,
                            );
                        });
                }),
            );
        });

        describe('extractModel', function() {
            it('should return the model of a JSON API response', function() {
                var model = { id: 1 };
                expect(
                    httpProxy.extractModel({
                        data: model,
                    }),
                ).toBe(model);
            });
        });

        describe('extractModels', function() {
            it('should return the model of a JSON API response', function() {
                var models = [{ id: 1 }, { id: 2 }, { id: 3 }];
                expect(
                    httpProxy.extractModel({
                        data: models,
                    }),
                ).toBe(models);
            });
        });
    });
});
