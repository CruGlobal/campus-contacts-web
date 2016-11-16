(function () {

    'use strict';

    // Constants
    var myContactsDashboardService, httpProxy, $rootScope, $q, JsonApiDataStore, periodService, _;

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

    describe('myContactsDashboardService Tests', function () {


        beforeEach(angular.mock.module('missionhubApp'));

        beforeEach(inject(function (_$q_, _$rootScope_, _myContactsDashboardService_,
                                    _httpProxy_, _JsonApiDataStore_, _periodService_, ___) {

            var _this = this;

            $q = _$q_;
            $rootScope = _$rootScope_;
            httpProxy = _httpProxy_;
            JsonApiDataStore = _JsonApiDataStore_;
            periodService = _periodService_;
            myContactsDashboardService = _myContactsDashboardService_;
            _ = ___;


            this.person = {
                personId: 123
            };

            this.people = [
                {
                    personId: 123
                },
                {
                    personId: 234
                }
            ];

            this.peopleReports = {
                reportId: 123
            };

            this.organizationReports = {
                reportId: 123
            };

            this.peopleReportsParams = {
                organization_ids: [123],
                people_ids: [456]
            };

            this.loadOrganizationReportsParams = {
                organization_ids: 456
            };

            this.loadOrganizationParams = {
                'page[limit]': 100,
                order: 'active_people_count',
                include: ''
            };

            spyOn(httpProxy, 'callHttp').and.callFake(function () {
                return $q.resolve(_this.httpResponse);
            });

            spyOn(JsonApiDataStore.store, 'sync').and.returnValue(_this.httpResponse);

        }));
        describe('People Tests', function () {
            it('should contain loadPeople', function () {
                expect(myContactsDashboardService.loadPeople).toBeDefined();
            });

            it('should call GET loadPeople URL', function () {
                var params = {
                    'page[limit]': 250,
                    include: 'phone_numbers,email_addresses,reverse_contact_assignments.organization,' +
                    'organizational_permissions',
                    'filters[assigned_tos]': 'me'
                };
                myContactsDashboardService.loadPeople(params);
                expect(httpProxy.callHttp).toHaveBeenCalledWith(
                    'GET',
                    jasmine.any(String),
                    params
                );
            });

            it('should load people', async(function () {
                this.httpResponse = this.people;

                var _this = this;
                return myContactsDashboardService.loadPeople().then(function (loadedPeople) {
                    expect(loadedPeople).toEqual(_this.people);
                });
            }));

            it('should sync people JsonApiDataStore', async(function () {
                this.httpResponse = this.people;

                var _this = this;
                JsonApiDataStore.store.sync('people', this.people);
                return myContactsDashboardService.loadPeople().then(function () {
                    expect(JsonApiDataStore.store.sync).toHaveBeenCalledWith('people', _this.people);
                });
            }));

        });


        describe('Reports Tests', function () {

            describe('People Reports', function () {
                it('should contain loadPeopleReports', function () {
                    expect(myContactsDashboardService.loadPeopleReports).toBeDefined();
                });

                it('should call GET loadPeopleReports URL', function () {

                    var joinedParams = _.clone(this.peopleReportsParams);
                    joinedParams.organization_ids = joinedParams.organization_ids.join(',');
                    joinedParams.people_ids = joinedParams.people_ids.join(',');
                    spyOn(periodService, 'getPeriod').and.returnValue('period');
                    myContactsDashboardService.loadPeopleReports(this.peopleReportsParams);
                    expect(httpProxy.callHttp).toHaveBeenCalledWith(
                        'GET',
                        jasmine.any(String),
                        _.extend(joinedParams, { period: 'period' })
                    );
                });

                it('should load people reports', async(function () {
                    this.httpResponse = this.peopleReports;

                    var _this = this;

                    return myContactsDashboardService.loadPeopleReports(this.peopleReportsParams)
                        .then(function (loadedPeopleReports) {
                            expect(loadedPeopleReports).toEqual(_this.peopleReports);
                        });
                }));

                it('should sync people Reports JsonApiDataStore', async(function () {
                    this.httpResponse = this.peopleReports;

                    var _this = this;
                    JsonApiDataStore.store.sync('peopleReports', this.peopleReports);
                    return myContactsDashboardService.loadPeopleReports(this.peopleReportsParams).then(function () {
                        expect(JsonApiDataStore.store.sync).toHaveBeenCalledWith('peopleReports', _this.peopleReports);
                    });

                }));
            });
        });

        describe('Organization loading', function () {
            it('should contain load Organization', function () {
                expect(myContactsDashboardService.loadOrganizations).toBeDefined();
            });

            it('should call GET loadOrganization URL', function () {
                myContactsDashboardService.loadOrganizations(this.loadOrganizationParams);
                expect(httpProxy.callHttp).toHaveBeenCalledWith(
                    'GET',
                    jasmine.any(String),
                    this.loadOrganizationParams
                );
            });

            it('should load Organization', async(function () {
                this.httpResponse = { data: this.organizationReports };

                var _this = this;

                return myContactsDashboardService.loadOrganizations(this.loadOrganizationParams)
                    .then(function (loadedOrganization) {
                        expect(loadedOrganization).toEqual(_this.organizationReports);
                    });
            }));
        });

    });
})();
