(function () {

    'use strict';

    // Constants
    var httpProxy;

    describe('HttpProxyService Tests', function () {


        beforeEach(angular.mock.module('missionhubApp'));

        beforeEach(inject(function (_httpProxy_) {
            httpProxy = _httpProxy_;
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
    });

})();