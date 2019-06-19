import template from './organizationOverview.html';
import './organizationOverview.scss';

import { t } from 'i18next';

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
    $uibModal,
    userPreferencesService,
    confirmModalService,
    _,
) {
    this.tabNames = ministryViewTabs;
    this.adminPrivileges = true;
    this.p2cOrg = false;
    this.toggleVisibility = userPreferencesService.toggleOrganizationVisibility;
    this.surveyResponses = 'countHidden';

    this.isInsightsTab = () => {
        return $state.current.name === 'app.ministries.ministry.insights';
    };

    this.isTabVisible = tabName => {
        return (
            tabName !== 'labels' &&
            !(tabName === 'surveys' && !this.directAdminPrivileges)
        );
    };

    this.showOrgNav = () =>
        !$state.$current.name.match(
            /^app\.ministries\.ministry\.(survey\.|import|management|reportMovementIndicators|cleanup|signatures)/,
        );

    this.$onInit = asyncBindingsService.lazyLoadedActivate(activate, ['org']);

    function activate() {
        _.defaults(this, {
            loadDetails: true,
        });

        this.adminPrivileges = loggedInPerson.isAdminAt(this.org);
        this.directAdminPrivileges = loggedInPerson.isDirectAdminAt(this.org);

        const rootOrgId = organizationService.getOrgHierarchyIds(this.org)[0];

        this.p2cOrg = this.org.id === p2cOrgId || rootOrgId === p2cOrgId;

        if (!this.loadDetails) {
            // Abort before loading org details
            return;
        }

        // Make groups and surveys mirror that property on the organization
        $scope.$watch('$ctrl.org.groups', () => {
            this.groups = this.org.groups;
        });
        $scope.$watch('$ctrl.org.surveys', () => {
            this.surveys = this.org.surveys;
        });

        // Find all of the groups and surveys related to the org
        organizationOverviewService.loadOrgRelations(this.org);

        // The suborgs, people, and team are loaded by their respective tab components, not this component.
        // However, this component does need to know how many people and team members there are, so set the
        // people and team to a sparse array of the appropriate length.
        organizationOverviewService
            .getSubOrgCount(this.org)
            .then(subOrgCount => {
                this.suborgs = new Array(subOrgCount);
            });
        organizationOverviewService
            .getPersonCount(this.org)
            .then(personCount => {
                this.people = new Array(personCount);
            });
        organizationOverviewService
            .getTeamCount(this.org)
            .then(teamMemberCount => {
                this.team = new Array(teamMemberCount);
            });
    }
}
