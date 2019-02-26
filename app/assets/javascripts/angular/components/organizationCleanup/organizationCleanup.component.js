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

    this.archiveInactive = archiveContacts('leaders_last_sign_in_at');
    this.archiveBefore = archiveContacts('persons_inactive_since');
}
