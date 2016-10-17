(function () {

    'use strict';

    // Constants
    var httpProxy;
    var JsonApiDataStore;
    var $rootScope;

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

        beforeEach(inject(function (_httpProxy_, _$rootScope_, _JsonApiDataStore_) {
            httpProxy = _httpProxy_;
            $rootScope = _$rootScope_;
            JsonApiDataStore = _JsonApiDataStore_;
        }));

        it('service should exist', function () {
            expect(httpProxy).toBeDefined();
        });

        it('should contain get', function () {
            expect(httpProxy.get).toBeDefined();
        });

        it('should contain post', function () {
            expect(httpProxy.post).toBeDefined();
        });

        it('should contain put', function () {
            expect(httpProxy.put).toBeDefined();
        });

        it('should contain delete', function () {
            expect(httpProxy.delete).toBeDefined();
        });

        it('contain callHttp', function () {
            expect(httpProxy.callHttp).toBeDefined();
        });

        it('http proxy can make fake async call', inject(function () {
            var spy = spyOn(httpProxy, 'callHttp').and.callFake(function(){});
            httpProxy.callHttp();
            expect(spy).toHaveBeenCalled();
        }));

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
                })
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
                    spyOn(JsonApiDataStore.store, 'find').and.returnValues(null, this.model);
                    spyOn(httpProxy, 'getUnloadedRelationships').and.returnValue([]);

                    var _this = this;
                    return httpProxy.getModel(this.url, this.type, this.id, this.relationships).then(function (model) {
                        expect(model).toBe(_this.model);
                        expect(httpProxy.callHttp).not.toHaveBeenCalled();
                    });
                }));

                it('should make a network request when the model is not already loaded', asynchronous(function () {
                    spyOn(JsonApiDataStore.store, 'find').and.returnValues(this.model, this.model);
                    spyOn(httpProxy, 'getUnloadedRelationships').and.returnValue(['a', 'b', 'c']);

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
        });
    });

})();
