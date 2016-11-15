(function () {

    'use strict';

    // Constants
    var httpProxy;
    var $rootScope;
    var $http;
    var JsonApiDataStore;

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

    describe('HttpProxyService Tests', function () {

        beforeEach(angular.mock.module('missionhubApp'));

        beforeEach(function () {
            var _this = this;
            this.token = null;
            this.responseData = {};
            this.responseHeaders = {
                get 'x-mh-session' () {
                    return _this.token;
                }
            };
            this.httpResponse = {
                headers: function (header) {
                    return _this.responseHeaders[header];
                },
                get data () {
                    return _this.responseData;
                }
            };

            // Mock out the $http service
            angular.mock.module(function ($provide) {
                $provide.factory('$http', function ($q) {
                    var $http = jasmine.createSpy('$http').and.returnValue($q.resolve(_this.httpResponse));
                    $http.defaults = { headers: { common: {} } };
                    return $http;
                });
            });
        });

        beforeEach(inject(function (_httpProxy_, _$rootScope_, _$http_, _JsonApiDataStore_) {
            httpProxy = _httpProxy_;
            $rootScope = _$rootScope_;
            $http = _$http_;
            JsonApiDataStore = _JsonApiDataStore_;
        }));

        describe('callHttp', function () {
            beforeEach(inject(function (envService) {
                this.apiUrl = 'http://localhost:4000';
                this.method = 'GET';
                this.url = '/';
                this.params = { key1: 'value1' };
                this.data = { key2: 'value2' };

                spyOn(envService, 'read').and.returnValue(this.apiUrl);
            }));

            it('should get the base API url from envService', inject(function (envService) {
                httpProxy.callHttp(this.method, this.url, this.params, this.data);
                expect(envService.read).toHaveBeenCalledWith('apiUrl');

                var httpConfig = $http.calls.argsFor(0)[0];
                expect(httpConfig.url.indexOf(this.apiUrl)).toBe(0);
            }));

            it('should call $http', function () {
                httpProxy.callHttp(this.method, this.url, this.params, this.data);
                expect($http).toHaveBeenCalledWith({
                    method: this.method,
                    url: this.apiUrl + this.url,
                    data: this.data,
                    params: this.params
                });
            });

            it('should set the Authorization header when a token is received', asynchronous(function () {
                var _this = this;
                this.token = 'abcde';
                this.responseData = { data: [] };
                spyOn(this.httpResponse, 'headers').and.callThrough();
                return httpProxy.callHttp(this.method, this.url, this.params, this.data).then(function () {
                    expect(_this.httpResponse.headers).toHaveBeenCalledWith('x-mh-session');
                    expect($http.defaults.headers.common.Authorization).toBe('Bearer ' + _this.token);
                });
            }));

            it('should not set the Authorization header when a token is not received', asynchronous(function () {
                var originalAuthorization = 'Bearer old';
                this.token = null;
                $http.defaults.headers.common.Authorization = originalAuthorization;
                return httpProxy.callHttp(this.method, this.url, this.params, this.data).then(function () {
                    expect($http.defaults.headers.common.Authorization).toBe(originalAuthorization);
                });
            }));

            it('should sync the JSON store with the response', asynchronous(function () {
                var _this = this;
                spyOn(JsonApiDataStore.store, 'syncWithMeta');
                return httpProxy.callHttp(this.method, this.url, this.params, this.data).then(function () {
                    expect(JsonApiDataStore.store.syncWithMeta).toHaveBeenCalledWith(_this.responseData);
                });
            }));

            describe('aliases', function () {
                beforeEach(function () {
                    spyOn(httpProxy, 'callHttp');
                });

                it('should contain get', function () {
                    httpProxy.get(this.url, this.params);
                    expect(httpProxy.callHttp).toHaveBeenCalledWith('GET', this.url, this.params);
                });

                it('should contain post', function () {
                    httpProxy.post(this.url, this.params, this.data);
                    expect(httpProxy.callHttp).toHaveBeenCalledWith('POST', this.url, this.params, this.data);
                });

                it('should contain put', function () {
                    httpProxy.put(this.url, this.params, this.data);
                    expect(httpProxy.callHttp).toHaveBeenCalledWith('PUT', this.url, this.params, this.data);
                });

                it('should contain delete', function () {
                    httpProxy.delete(this.url, this.params);
                    expect(httpProxy.callHttp).toHaveBeenCalledWith('DELETE', this.url, this.params);
                });
            });
        });

        describe('model loading', function () {
            beforeEach(function () {
                this.loadedModel = {};
                this.placeholderModel = { _placeHolder: true };
            });

            describe('isLoaded', function () {
                it('should treat null models as unloaded', function () {
                    expect(httpProxy.isLoaded(null)).toBe(false);
                });

                it('should treat a placeholder model as unloaded', function () {
                    expect(httpProxy.isLoaded(this.placeholderModel)).toBe(false);
                });

                it('should treat a model as loaded', function () {
                    expect(httpProxy.isLoaded(this.loadedModel)).toBe(true);
                });
            });

            describe('getUnloadedRelationships', function () {
                it('should treat all relationships as unloaded when the model is null', function () {
                    this.relationships = ['a', 'b', 'c'];
                    expect(httpProxy.getUnloadedRelationships(null, this.relationships))
                        .toEqual(this.relationships);
                });

                it('should treat all relationships as unloaded when the model is a placeholder', function () {
                    this.relationships = ['a', 'b', 'c'];
                    expect(httpProxy.getUnloadedRelationships(this.placeholderModel, this.relationships))
                        .toEqual(this.relationships);
                });

                it('should correctly detect unloaded relationships', function () {
                    this.model = {
                        a: [],
                        b: [
                            this.loadedModel
                        ],
                        c: [
                            this.placeholderModel
                        ],
                        d: [
                            this.loadedModel,
                            this.placeholderModel
                        ],
                        e: [
                            { a: this.loadedModel }
                        ],
                        f: [
                            { a: this.placeholderModel }
                        ],
                        g: [
                            { a: this.loadedModel },
                            { a: this.placeholderModel }
                        ],
                        h: [
                            { a: { b: { c: this.loadedModel } } }
                        ],
                        i: [
                            { a: { b: { c: this.placeholderModel } } }
                        ],
                        j: [
                            { a: this.placeholderModel }
                        ]
                    };
                    this.relationships = ['a', 'b', 'c', 'd', 'e.a', 'f.a', 'g.a', 'h.a.b.c', 'i.a.b.c', 'j.a.b.c'];
                    expect(httpProxy.getUnloadedRelationships(this.model, this.relationships))
                        .toEqual(['c', 'd', 'f.a', 'g.a', 'i.a.b.c', 'j.a.b.c']);
                });
            });

            describe('getModel', function () {
                beforeEach(function () {
                    this.url = '/';
                    this.type = 'abc';
                    this.id = 123;
                    this.model = { id: this.id };
                    this.relationships = ['a', 'b', 'c'];
                    this.requestParams = { key: 'value' };

                    spyOn(httpProxy, 'callHttp');
                });

                it('should not make a network request when the model is already loaded', asynchronous(function () {
                    spyOn(JsonApiDataStore.store, 'find').and.returnValues(this.model, this.model);
                    spyOn(httpProxy, 'getUnloadedRelationships').and.returnValue([]);

                    var _this = this;
                    return httpProxy.getModel(this.url, this.type, this.id, this.relationships).then(function (model) {
                        expect(model).toBe(_this.model);
                        expect(httpProxy.callHttp).not.toHaveBeenCalled();
                    });
                }));

                it('should make a network request when the model is not already loaded', asynchronous(function () {
                    spyOn(JsonApiDataStore.store, 'find').and.returnValues(null, this.model);
                    spyOn(httpProxy, 'getUnloadedRelationships').and.returnValue([]);

                    var _this = this;
                    return httpProxy.getModel(this.url, this.type, this.id, this.relationships, this.requestParams)
                        .then(function (model) {
                            expect(model).toBe(_this.model);
                            expect(httpProxy.callHttp).toHaveBeenCalledWith('GET', _this.url, {
                                key: 'value',
                                include: ''
                            });
                        });
                }));

                it('should make a network request when the model relationships are not already loaded', asynchronous(function () {
                    spyOn(JsonApiDataStore.store, 'find').and.returnValues(this.model, this.model);
                    spyOn(httpProxy, 'getUnloadedRelationships').and.returnValue(this.relationships);

                    var _this = this;
                    return httpProxy.getModel(this.url, this.type, this.id, this.relationships, this.requestParams)
                        .then(function (model) {
                            expect(model).toBe(_this.model);
                            expect(httpProxy.callHttp).toHaveBeenCalledWith('GET', _this.url, {
                                key: 'value',
                                include: 'a,b,c'
                            });
                        });
                }));
            });

            describe('extractModel', function () {
                it('should return the model of a JSON API response', function () {
                    var model = { id: 1 };
                    expect(httpProxy.extractModel({
                        data: model
                    })).toBe(model);
                });
            });

            describe('extractModels', function () {
                it('should return the model of a JSON API response', function () {
                    var models = [{ id: 1 }, { id: 2 }, { id: 3 }];
                    expect(httpProxy.extractModel({
                        data: models
                    })).toBe(models);
                });
            });
        });
    });

})();
