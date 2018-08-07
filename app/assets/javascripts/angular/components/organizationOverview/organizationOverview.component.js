import template from './organizationOverview.html';
import './organizationOverview.scss';

angular.module('missionhubApp').component('organizationOverview', {
    controller: organizationOverviewController,
    bindings: {
        org: '<',
        loadDetails: '<?',
        editMode: '<?',
    },
    template: template,
});

function organizationOverviewController(
    $scope,
    $state,
    p2cOrgId,
    asyncBindingsService,
    ministryViewTabs,
    organizationOverviewService,
    organizationService,
    loggedInPerson,
    userPreferencesService,
    _,
) {
    var vm = this;
    vm.tabNames = ministryViewTabs;
    vm.adminPrivileges = true;
    vm.cruOrg = false;
    vm.p2cOrg = false;
    vm.toggleVisibility = userPreferencesService.toggleOrganizationVisibility;

    vm.showOrgNav = () => {
        return $state.$current.name !== 'app.ministries.ministry.import';
    };

    vm.$onInit = asyncBindingsService.lazyLoadedActivate(activate, ['org']);

    function activate() {
        _.defaults(vm, {
            loadDetails: true,
        });

        vm.adminPrivileges = loggedInPerson.isAdminAt(vm.org);

        var cruOrgId = '1';
        var rootOrgId = organizationService.getOrgHierarchyIds(vm.org)[0];
        vm.cruOrg = rootOrgId === cruOrgId;

        vm.p2cOrg = vm.org.id === p2cOrgId || rootOrgId === p2cOrgId;

        if (!vm.loadDetails) {
            // Abort before loading org details
            return;
        }

        // Make groups and surveys mirror that property on the organization
        $scope.$watch('$ctrl.org.groups', function() {
            vm.groups = vm.org.groups;
        });
        $scope.$watch('$ctrl.org.surveys', function() {
            vm.surveys = vm.org.surveys;
        });

        // Find all of the groups and surveys related to the org
        organizationOverviewService.loadOrgRelations(vm.org);

        // The suborgs, people, and team are loaded by their respective tab components, not this component.
        // However, this component does need to know how many people and team members there are, so set the
        // people and team to a sparse array of the appropriate length.
        organizationOverviewService
            .getSubOrgCount(vm.org)
            .then(function(subOrgCount) {
                vm.suborgs = new Array(subOrgCount);
            });
        organizationOverviewService
            .getPersonCount(vm.org)
            .then(function(personCount) {
                vm.people = new Array(personCount);
            });
        organizationOverviewService
            .getTeamCount(vm.org)
            .then(function(teamMemberCount) {
                vm.team = new Array(teamMemberCount);
            });
    }
}
