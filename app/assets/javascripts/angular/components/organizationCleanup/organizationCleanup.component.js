import template from './organizationCleanup.html';
import './organizationCleanup.scss';
import checkIcon from '../../../../images/icons/icon-check.svg';

angular.module('missionhubApp').component('organizationCleanup', {
    bindings: {
        orgId: '<',
    },
    template: template,
    controller: organizationCleanupController,
});

function organizationCleanupController(httpProxy, $scope) {
    this.archiveBeforeDate = new Date();
    this.archiveInactivityDate = new Date();
    this.dateOptions = {
        formatYear: 'yy',
        maxDate: new Date(2020, 5, 22),
        minDate: new Date(),
        startingDay: 1,
    };
    this.cleanupCompleted = false;
    this.checkIcon = checkIcon;

    const archiveContacts = (archiveBy, dateBy) => {
        this.cleanupCompleted = false;

        const data = {
            type: 'bulk_archive_contacts',
            id: this.orgId,
            attributes: {
                organization_id: this.orgId,
                before_date: dateBy,
                archive_by: archiveBy,
                archived: true,
            },
        };

        return httpProxy.post(
            '/organizations/archives',
            {
                data: data,
            },
            {
                errorMessage: 'error.messages.organization.cleanup',
            },
        );
    };

    this.archiveInactive = async dateBy => {
        if (!dateBy) return;

        const { data } = await archiveContacts(
            'leaders_last_sign_in_at',
            dateBy,
        );

        if (data) this.cleanupCompleted = true;

        $scope.$apply();
    };

    this.archiveBefore = async dateBy => {
        if (!dateBy) return;

        const { data } = await archiveContacts(
            'persons_inactive_since',
            dateBy,
        );

        if (data) this.cleanupCompleted = true;

        $scope.$apply();
    };
}
