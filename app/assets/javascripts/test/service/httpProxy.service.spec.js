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

        beforeEach(inject(function (_httpProxy_, $q) {
            httpProxy = _httpProxy_;

            spyOn(httpProxy, 'callHttp').and.callFake(function(){
                var deferred = $q.defer();
                deferred.resolve('success');
                return deferred.promise;
            });

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

        it('http proxy can make async call', inject(function () {
            var request = httpProxy.callHttp(config.method, config.url, config.params, config.data);

            var response = request.then(function(response){
                return response;
            });

            expect(httpProxy.callHttp).toHaveBeenCalled();
        }));

    });

})();