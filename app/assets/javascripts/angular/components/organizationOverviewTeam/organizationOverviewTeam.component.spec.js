(function () {
    'use strict';

    describe('organizationOverviewTeam component', function () {
        beforeEach(angular.mock.module('missionhubApp'));

        var $ctrl, $q, $rootScope, organizationOverviewTeamService, reportsService;

        beforeEach(inject(function ($componentController, _$q_, _$timeout_, _$rootScope_) {
            organizationOverviewTeamService = jasmine.createSpyObj('organizationOverviewTeamService', [
                'loadOrgTeam'
            ]);
            reportsService = jasmine.createSpyObj('reportsService', [
                'loadMultiplePeopleReports'
            ]);

            $ctrl = $componentController('organizationOverviewTeam',
                                         {
                                             organizationOverviewTeamService: organizationOverviewTeamService,
                                             reportsService: reportsService
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
            $rootScope = _$rootScope_;
        }));

        describe('loadTeamPage', function () {
            it('should load the people on the team', function () {
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
                expect(reportsService.loadMultiplePeopleReports).toHaveBeenCalledWith([1], 'teamList');
                expect($ctrl.loadedAll).toEqual(true);
                expect($ctrl.busy).toEqual(false);
            });
        });
    });
})();
