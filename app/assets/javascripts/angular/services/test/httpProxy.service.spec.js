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

        it('http proxy should exist', function() {
            expect(httpProxy).toBeDefined();
        });

    });

})();