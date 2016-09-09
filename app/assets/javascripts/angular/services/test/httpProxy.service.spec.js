(function () {

    'use strict';

    // Constants
    var I18n;
    var httpProxy;

    describe('HttpProxyService Tests', function () {

        beforeEach(angular.mock.module('ngAnimate'));
        beforeEach(angular.mock.module('ngMdIcons'));

        beforeEach(inject(function(_I18n_){
            I18n = _I18n_;
            I18n.fallbacks = true;
        }));

        beforeEach(angular.mock.module('missionhubApp'));

        beforeEach(inject(function(_httpProxy_){
            httpProxy = _httpProxy_;
        }));

        it('http proxy should exist', function(){
            expect(http).toBeDefined();
        });

    });

})();