(function () {

    'use strict';

    // Constants
    var $q, $rootScope, reportsService, httpProxy, periodService;

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
            reportsService = _reportsService_;
            httpProxy = _httpProxy_;
            periodService = _periodService_;

            this.period = '1d';
            this.orgIds = [123, 456, 789];
            this.report1 = { id: '123-1d' };
            this.report2 = { id: '456-1d' };
            this.report3 = { id: '789-1d' };

            this.report = {
                interactions: [
                    { interaction_type_id: 1, interaction_count: 1 },
                    { interaction_type_id: 2, interaction_count: 5 },
                    { interaction_type_id: 3, interaction_count: 10 }
                ]
            };

            spyOn(httpProxy, 'callHttp').and.returnValue($q.resolve());
        }));


        describe('loadOrganizationReports', function () {
            beforeEach(function () {
                spyOn(periodService, 'getPeriod').and.returnValue(this.period);
            });

            it('should GET the organization reports URL', function () {
                spyOn(reportsService, 'lookupOrganizationReport').and.returnValues(
                    null, null, null
                );
                reportsService.loadOrganizationReports(this.orgIds);
                expect(httpProxy.callHttp).toHaveBeenCalledWith('GET', '/reports/organizations', {
                    organization_ids: '123,456,789',
                    period: this.period
                });
            });

            it('should only load reports that are not already loaded', function () {
                spyOn(reportsService, 'lookupOrganizationReport').and.returnValues(
                    null, this.report2, null
                );
                var promise = reportsService.loadOrganizationReports(this.orgIds);
                expect(httpProxy.callHttp).toHaveBeenCalledWith('GET', '/reports/organizations', {
                    organization_ids: '123,789',
                    period: this.period
                });
            });

            it('should not make a network request when all reports are already loaded', function () {
                spyOn(reportsService, 'lookupOrganizationReport').and.returnValues(
                    this.report1, this.report2, this.report3
                );
                reportsService.loadOrganizationReports(this.orgIds);
                expect(httpProxy.callHttp).not.toHaveBeenCalled();
            });

            it('should return a promise that resolves to an array of organization reports ' +
               'when a network request is required', async(function () {
                var _this = this;
                spyOn(reportsService, 'lookupOrganizationReport').and.returnValues(
                    null, null, null,
                    this.report1, this.report2, this.report3
                );

                return reportsService.loadOrganizationReports(this.orgIds)
                    .then(function (loadedOrganizationReports) {
                        expect(loadedOrganizationReports).toEqual([_this.report1, _this.report2, _this.report3]);
                    });
            }));

            it('should return a promise that resolves to an array of organization reports ' +
               'when a network request is not required', async(function () {
                var _this = this;
                spyOn(reportsService, 'lookupOrganizationReport').and.returnValues(
                    this.report1, this.report2, this.report3,
                    this.report1, this.report2, this.report3
                );

                return reportsService.loadOrganizationReports(this.orgIds)
                    .then(function (loadedOrganizationReports) {
                        expect(loadedOrganizationReports).toEqual([_this.report1, _this.report2, _this.report3]);
                    });
            }));
        });

        describe('getInteractionCount', function () {
            it('should return the interaction count', function () {
                expect(reportsService.getInteractionCount(this.report, 1)).toBe(1);
            });

            it('should return no data with a report not containing interactions of a certain type', function () {
                expect(reportsService.getInteractionCount(this.report, 5)).toBe('-');
            });

            it('should return no data with no report', function () {
                expect(reportsService.getInteractionCount(null, 1)).toBe('-');
            });
        });

        describe('incrementReportInteraction', function () {
            it('increment existing interaction counts', function () {
                reportsService.incrementReportInteraction(this.report, 1);
                expect(this.report.interactions).toEqual([
                    { interaction_type_id: 1, interaction_count: 2 },
                    { interaction_type_id: 2, interaction_count: 5 },
                    { interaction_type_id: 3, interaction_count: 10 }
                ]);
            });

            it('create non-existent interaction counts', function () {
                reportsService.incrementReportInteraction(this.report, 5);
                expect(this.report.interactions).toEqual([
                    { interaction_type_id: 1, interaction_count: 1 },
                    { interaction_type_id: 2, interaction_count: 5 },
                    { interaction_type_id: 3, interaction_count: 10 },
                    { interaction_type_id: 5, interaction_count: 1 }
                ]);
            });
        });
    });

})();
