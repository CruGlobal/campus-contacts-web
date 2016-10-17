(function () {

    'use strict';

    // Constants
    var $q, $rootScope, reportsSerivce, httpProxy, periodService;

    function async (fn) {
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

    describe('ReportsService Tests', function () {

        beforeEach(angular.mock.module('missionhubApp'));

        beforeEach(inject(function (_$q_, _$rootScope_, _reportsService_, _httpProxy_, _periodService_) {

            var _this = this;

            $q = _$q_;
            $rootScope = _$rootScope_;
            reportsSerivce = _reportsService_;
            httpProxy = _httpProxy_;
            periodService = _periodService_;

            this.loadOrganizationReportsParams = {
                organization_ids: '456'
            };

            spyOn(httpProxy, 'callHttp').and.callFake(function () {
                return _this.httpResponse;
            });
        }));


        describe('Organization Reports', function () {
            it('should contain loadOrganizationReports', function () {
                expect(reportsSerivce.loadOrganizationReports).toBeDefined();
            });

            it('should call GET load OrganizationReports URL', function () {
                spyOn(periodService, 'getPeriod').and.returnValue('period');
                reportsSerivce.loadOrganizationReports([456]);
                expect(httpProxy.callHttp).toHaveBeenCalledWith(
                    'GET',
                    '/reports/organizations',
                    _.extend(this.loadOrganizationReportsParams, { period: 'period' })
                );
            });

            it('should load OrganizationReports', async(function () {
                this.httpResponse = $q.resolve(
                    this.organizationReports
                );

                var _this = this;

                return reportsSerivce.loadOrganizationReports([456])
                    .then(function (loadedOrganizationReports) {
                        expect(loadedOrganizationReports).toEqual(_this.organizationReports);
                    });
            }));
        });
    });

})();