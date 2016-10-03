(function () {

    'use strict';

    // Constants
    var organizationalPeopleService, httpProxy, $rootScope;

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

    describe('organizationalPeopleService Tests', function () {

        beforeEach(angular.mock.module('ngAnimate'));
        beforeEach(angular.mock.module('ngMdIcons'));


        beforeEach(angular.mock.module('missionhubApp'));

        beforeEach(inject(function (_peopleService_, _httpProxy_, _$rootScope_) {

            var _this = this;

            httpProxy = _httpProxy_;
            organizationalPeopleService = _peopleService_;
            $rootScope = _$rootScope_;

            this.updateParams = {
                data: {
                    type: 'person',
                    attributes: {}
                },
                included: [
                    {
                        type: 'organizational_permission',
                        id: 123,
                        attributes: {
                            archive_date: (new Date()).toUTCString()
                        }
                    }
                ]
            };

            spyOn(httpProxy, 'callHttp').and.callFake(function () {
                return _this.httpResponse;
            });
        }));

        describe('organizationalPeople Service', function () {
            // Emmanuel marked this to be ignored.for now. He will move it to its proper place soon.
            xit('should PUT a URL', function () {
                organizationalPeopleService.updatePeople(this.interaction.person_id, this.updateParams);
                expect(httpProxy.callHttp).toHaveBeenCalledWith(
                    'PUT',
                    jasmine.any(String),
                    null,
                    this.updateParams
                );
            });


        });

    });

})();