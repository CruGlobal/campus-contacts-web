(function () {

    'use strict';

    // Constants
    var httpProxy;

    describe('HttpProxyService Tests', function () {


        var config = {
            method: 'GET',
            url: '',
            data: {},
            params: {}
        };

        beforeEach(angular.mock.module('ngAnimate'));
        beforeEach(angular.mock.module('ngMdIcons'));


        beforeEach(angular.mock.module('missionhubApp'));

        beforeEach(inject(function (_httpProxy_) {
            httpProxy = _httpProxy_;

        }));

        it('http proxy should exist', function () {
            expect(httpProxy).toBeDefined();
        });

        it('http proxy should contain get', function () {
            expect(httpProxy.get).toBeDefined();
        });

        it('http proxy should contain post', function () {
            expect(httpProxy.post).toBeDefined();
        });

        it('http proxy should contain put', function () {
            expect(httpProxy.put).toBeDefined();
        });

        it('http proxy should contain delete', function () {
            expect(httpProxy.delete).toBeDefined();
        });

        it('http proxy should contain callHttp', function () {
            expect(httpProxy.callHttp).toBeDefined();
        });

        it('http proxy can make fake async call', inject(function ($q) {
            var spy = spyOn(httpProxy, 'callHttp').and.callFake(function(){
                var deferred = $q.defer();
                deferred.resolve('success');
                return deferred.promise;
            });

            httpProxy.callHttp();
            expect(spy).toHaveBeenCalled();
        }));

        it('http proxy can make async call', inject(function ($q) {
            var spy = spyOn(httpProxy, 'callHttp').and.callThrough(function(){
                var deferred = $q.defer();
                deferred.resolve('success');
                return deferred.promise;
            });

            httpProxy.callHttp();
            expect(spy).toHaveBeenCalled();
        }));

    });

})();