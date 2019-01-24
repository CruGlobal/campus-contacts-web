import template from './organizationCleanup.html';
import './organizationCleanup.scss';

angular.module('missionhubApp').component('organizationCleanup', {
    bindings: {
        orgId: '<',
    },
    template: template,
    controller: organizationCleanupController,
});

function organizationCleanupController(httpProxy) {
    this.archiveBeforeDate = new Date();
    this.archiveInactivityDate = new Date();
    this.dateOptions = {
        formatYear: 'yy',
        maxDate: new Date(2020, 5, 22),
        minDate: new Date(),
        startingDay: 1,
    };

    const archiveContacts = async (archiveBy, dateBy) => {
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

        return await httpProxy.post(
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

        const { data } = archiveContacts('leaders_last_sign_in_at', dateBy);
    };

    this.archiveBefore = async dateBy => {
        if (!dateBy) return;

        const { data } = archiveContacts('persons_inactive_since', dateBy);
    };
}
