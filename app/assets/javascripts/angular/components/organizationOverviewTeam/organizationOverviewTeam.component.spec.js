(function () {
    'use strict';

    describe('organizationOverviewTeam component', function () {
        beforeEach(angular.mock.module('missionhubApp'));

        var $ctrl, $q, $log, $rootScope, organizationOverviewTeamService, myPeopleDashboardService;

        beforeEach(inject(function ($componentController, _$q_, _$timeout_, _$log_, _$rootScope_) {
            organizationOverviewTeamService = jasmine.createSpyObj('organizationOverviewTeamService', [
                'loadOrgTeam'
            ]);
            myPeopleDashboardService = jasmine.createSpyObj('myPeopleDashboardService', [
                'loadPeopleReports'
            ]);

            $ctrl = $componentController('organizationOverviewTeam',
                                         {
                                             organizationOverviewTeamService: organizationOverviewTeamService,
                                             myPeopleDashboardService: myPeopleDashboardService
                                         },
                                         {
                                             organizationOverview: {
                                                 org: {
                                                     id: 1
                                                 }
                                             }
                                         }
            );
            $q = _$q_;
            $log = _$log_;
            $rootScope = _$rootScope_;
        }));

        describe('loadTeamPage', function () {
            it('should load the people on the team', function () {
                spyOn($ctrl, '_loadReports');
                organizationOverviewTeamService.loadOrgTeam.and.returnValue(
                    $q.resolve({
                        list: 'teamList',
                        loadedAll: true
                    })
                );
                $ctrl.loadTeamPage();
                expect(organizationOverviewTeamService.loadOrgTeam).toHaveBeenCalledWith(
                    { id: 1 },
                    jasmine.any(Object)
                );
                $rootScope.$digest();
                expect($ctrl.team).toEqual('teamList');
                expect($ctrl._loadReports).toHaveBeenCalledWith('teamList');
                expect($ctrl.loadedAll).toEqual(true);
                expect($ctrl.busy).toEqual(false);
            });
        });

        describe('loadReports', function () {
            it('should load the reports for the team', function () {
                myPeopleDashboardService.loadPeopleReports.and.returnValue(
                    $q.resolve('success')
                );
                $ctrl._loadReports([{ id: 2 }]);
                expect(myPeopleDashboardService.loadPeopleReports).toHaveBeenCalledWith({
                    organization_ids: [1],
                    people_ids: [2]
                });
            });
            it('should handle an error', function () {
                myPeopleDashboardService.loadPeopleReports.and.returnValue(
                    $q.reject('error')
                );
                $ctrl._loadReports([{ id: 2 }]);
                expect(myPeopleDashboardService.loadPeopleReports).toHaveBeenCalledWith({
                    organization_ids: [1],
                    people_ids: [2]
                });
                $rootScope.$digest();
                expect($log.error.logs[0]).toEqual(['Error loading team people reports', 'error']);
            });
        });
    });
})();
