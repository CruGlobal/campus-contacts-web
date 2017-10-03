(function () {
    'use strict';

    // Constants
    var $q, $rootScope, reportsService, httpProxy, JsonApiDataStore, periodService;

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

    describe('reportsService', function () {
        beforeEach(angular.mock.module('missionhubApp'));

        beforeEach(inject(function (_$q_, _$rootScope_, _reportsService_,
                                    _httpProxy_, _JsonApiDataStore_, _periodService_) {
            var _this = this;

            $q = _$q_;
            $rootScope = _$rootScope_;
            reportsService = _reportsService_;
            httpProxy = _httpProxy_;
            JsonApiDataStore = _JsonApiDataStore_;
            periodService = _periodService_;

            this.period = '1d';
            this.orgId = 1;
            this.personId = 2;
            this.organizationReport = { id: '1-1d' };
            this.personReport = { id: '1-2-1d' };
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

            this.httpResponse = {};
            spyOn(httpProxy, 'callHttp').and.callFake(function () {
                return $q.resolve(_this.httpResponse);
            });
            spyOn(periodService, 'getPeriod').and.returnValue(this.period);
        }));

        describe('lookupOrganizationReport', function () {
            it('should return the found report if it exists', function () {
                spyOn(JsonApiDataStore.store, 'find').and.returnValue(this.organizationReport);
                expect(reportsService.lookupOrganizationReport(this.orgId)).toBe(this.organizationReport);
            });

            it('should return a placeholder report if it does not exist', function () {
                spyOn(JsonApiDataStore.store, 'find').and.returnValue(null);
                expect(reportsService.lookupOrganizationReport(this.orgId)).toEqual(jasmine.objectContaining({
                    id: this.organizationReport.id,
                    contact_count: 0,
                    uncontacted_count: 0,
                    _placeHolder: true,
                    interactions: []
                }));
            });
        });

        describe('lookupPersonReport', function () {
            it('should return the found report if it exists', function () {
                spyOn(JsonApiDataStore.store, 'find').and.returnValue(this.personReport);
                expect(reportsService.lookupPersonReport(this.orgId, this.personId)).toBe(this.personReport);
            });

            it('should return a placeholder report if it does not exist', function () {
                spyOn(JsonApiDataStore.store, 'find').and.returnValue(null);
                expect(reportsService.lookupPersonReport(this.orgId, this.personId)).toEqual(jasmine.objectContaining({
                    id: this.personReport.id,
                    contact_count: 0,
                    uncontacted_count: 0,
                    _placeHolder: true,
                    interactions: []
                }));
            });
        });

        describe('loadPersonReport', function () {
            it('should try to find the existing person report', function () {
                spyOn(JsonApiDataStore.store, 'find');
                reportsService.loadPersonReport(this.orgId, this.personId);
                expect(JsonApiDataStore.store.find).toHaveBeenCalledWith(
                    'person_report',
                    this.orgId + '-' + this.personId + '-' + this.period
                );
            });

            it('should make a network request if the report is not loaded', function () {
                spyOn(JsonApiDataStore.store, 'find').and.returnValue(null);
                reportsService.loadPersonReport(this.orgId, this.personId);
                expect(httpProxy.callHttp).toHaveBeenCalledWith(
                    'GET',
                    jasmine.any(String),
                    {
                        period: this.period,
                        organization_ids: this.orgId.toString(),
                        people_ids: this.personId.toString()
                    },
                    null,
                    jasmine.objectContaining({ errorMessage: jasmine.any(String) })
                );
            });

            it('should not make a network request if the report is loaded', function () {
                spyOn(JsonApiDataStore.store, 'find').and.returnValue(this.personReport);
                reportsService.loadPersonReport(this.orgId, this.personId);
                expect(httpProxy.callHttp).not.toHaveBeenCalled();
            });

            it('should return a promise that resolves to the report if it is already loaded', async(function () {
                var _this = this;
                spyOn(JsonApiDataStore.store, 'find').and.returnValue(this.personReport);
                return reportsService.loadPersonReport(this.orgId, this.personId).then(function (personReport) {
                    expect(personReport).toBe(_this.personReport);
                });
            }));

            it('should return a promise that resolves to the report if it is not already loaded', async(function () {
                var _this = this;
                spyOn(JsonApiDataStore.store, 'find').and.returnValue(null);
                this.httpResponse = {
                    data: [this.personReport]
                };
                return reportsService.loadPersonReport(this.orgId, this.personId).then(function (personReport) {
                    expect(personReport).toBe(_this.personReport);
                });
            }));
        });

        describe('loadOrganizationReports', function () {
            it('should GET the organization reports URL', function () {
                spyOn(reportsService, 'lookupOrganizationReport').and.returnValues(
                    null, null, null
                );
                reportsService.loadOrganizationReports(this.orgIds);
                expect(httpProxy.callHttp).toHaveBeenCalledWith('GET', '/reports/organizations', {
                    organization_ids: '123,456,789',
                    period: this.period
                }, null, jasmine.objectContaining({ errorMessage: jasmine.any(String) }));
            });

            it('should only load reports that are not already loaded', function () {
                spyOn(reportsService, 'lookupOrganizationReport').and.returnValues(
                    null, this.report2, null
                );
                reportsService.loadOrganizationReports(this.orgIds);
                expect(httpProxy.callHttp).toHaveBeenCalledWith('GET', '/reports/organizations', {
                    organization_ids: '123,789',
                    period: this.period
                }, null, jasmine.objectContaining({ errorMessage: jasmine.any(String) }));
            });

            it('should not make a network request when all reports are already loaded', function () {
                spyOn(reportsService, 'lookupOrganizationReport').and.returnValues(
                    this.report1, this.report2, this.report3
                );
                reportsService.loadOrganizationReports(this.orgIds);
                expect(httpProxy.callHttp).not.toHaveBeenCalled();
            });

            it('should asynchronously return an array of organization reports when a network request is required',
               async(function () {
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

            it('should asynchronously return an array of organization reports when a network request is not required',
               async(function () {
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
