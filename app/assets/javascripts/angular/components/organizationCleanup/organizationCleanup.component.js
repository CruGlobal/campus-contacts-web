import './organizationCleanup.scss';
import checkIcon from '../../../../images/icons/icon-check.svg';

import template from './organizationCleanup.html';

angular.module('missionhubApp').component('organizationCleanup', {
    bindings: {
        orgId: '<',
    },
    template: template,
    controller: organizationCleanupController,
});

function organizationCleanupController(
    httpProxy,
    $scope,
    $filter,
    $uibModal,
    $state,
) {
    this.archiveBeforeDate = new Date();
    this.archiveInactivityDate = new Date();
    this.checkIcon = checkIcon;

    const showConfirmModal = async title => {
        const archiveValue =
            title === 'ministries.cleanup.archive_by_inactivity_confirm_message'
                ? 'leaders_last_sign_in_at'
                : 'persons_inactive_since';
        const archiveDate =
            title === 'ministries.cleanup.archive_by_inactivity_confirm_message'
                ? this.archiveInactivityDate
                : this.archiveBeforeDate;

        const confirmModal = $uibModal.open({
            component: 'iconModal',
            resolve: {
                title: () => $filter('t')(title),
                closeLabel: () => $filter('t')('general.ok'),
                dismissLabel: () => $filter('t')('general.cancel'),
            },
            windowClass: 'pivot_theme',
            backdrop: 'static',
        });

        try {
            const modalResponse = await confirmModal.result;
            archiveContacts(archiveValue)(archiveDate);
        } catch (err) {}
    };

    const archiveContacts = archiveBy => async dateBy => {
        if (!dateBy) return;
        const params = {
            type: 'bulk_archive_contacts',
            id: this.orgId,
            attributes: {
                organization_id: this.orgId,
                before_date: dateBy,
                archive_by: archiveBy,
                archived: true,
            },
        };

        const { data } = await httpProxy.post(
            '/organizations/archives',
            {
                data: params,
            },
            {
                errorMessage: 'error.messages.organization.cleanup',
            },
        );

        if (data) {
            const modalInstance = $uibModal.open({
                component: 'iconModal',
                resolve: {
                    title: () =>
                        $filter('t')('ministries.cleanup.success_title'),
                    paragraphs: () => [
                        $filter('t')('ministries.cleanup.success_message'),
                    ],
                    icon: () => this.checkIcon,
                    closeLabel: () =>
                        $filter('t')('ministries.cleanup.success_cta'),
                },
                windowClass: 'pivot_theme',
                backdrop: 'static',
                keyboard: false,
            });

            const result = await modalInstance.result;
            $state.go('app.ministries.ministry.people', {
                orgId: this.orgId,
            });
        }

        $scope.$apply();
    };
    this.showConfirmModal = showConfirmModal;
}
