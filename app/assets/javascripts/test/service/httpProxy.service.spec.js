(function () {

    'use strict';

    // Constants
    var httpProxy;

    describe('HttpProxyService Tests', function () {

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

        it('http proxy can make fake async call', inject(function () {
            var spy = spyOn(httpProxy, 'callHttp').and.callFake(function(){});

            httpProxy.callHttp();
            expect(spy).toHaveBeenCalled();
        }));

        it('http proxy to have been called with arguments', inject(function ($q) {
            var spy = spyOn(httpProxy, 'callHttp').and.callFake(function(){});

            httpProxy.callHttp('POST', 'http://missionhub.com', null, {userId: 1, organizationId: 5});
            expect(spy).toHaveBeenCalledWith('POST', 'http://missionhub.com', null, {userId: 1, organizationId: 5});
        }));

        it('http proxy to have been called with proper arguments', inject(function ($q) {
            var spy = spyOn(httpProxy, 'callHttp').and.callFake(function(){});

            httpProxy.callHttp('POST', 'http://missionhub.com', null, {userId: 2, organizationId: 5});
            expect(spy).not.toHaveBeenCalledWith('POST', 'http://missionhub.com', null, {userId: 1, organizationId: 5});
        }));

    });

})();