import './organizationCleanup.scss';
import checkIcon from '../../../../images/icons/icon-check.svg';
import warningIcon from '../../../../images/icons/icon-warning-2.svg';

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
    this.warningIcon = warningIcon;

    // Opens up modal depending on the type
    const confirmModal = async (type, archiveDate) => {
        switch (type) {
            case 'archive_by_inactivity': {
                let archiveInactive = date => {
                    archiveContacts('leaders_last_sign_in_at')(date);
                };

                const InactiveModal = $uibModal.open({
                    component: 'iconModal',
                    resolve: {
                        title: () => $filter('t')(`Archive By Inactivity`),
                        paragraphs: () => [
                            $filter('t')(
                                `Are You Sure That You Wish To Archive By Inactivity?`,
                            ),
                        ],
                        icon: () => this.warningIcon,
                        closeLabel: () => $filter('t')('Yes'),
                        dismissLabel: () => $filter('t')('No'),
                    },
                    windowClass: 'pivot_theme',
                    backdrop: 'static',
                    keyboard: false,
                });
                // Had to throw in a catch for errors due to an AsyncGenerator.js error I was getting
                // In the console everytime the modal was dismissed
                try {
                    const InactiveResponse = await InactiveModal.result;
                    archiveInactive(archiveDate);
                } catch (err) {
                    return null;
                }

                break;
            }
            case 'archive_by_date': {
                let archiveBefore = date => {
                    archiveContacts('persons_inactive_since')(date);
                };
                const DateModal = $uibModal.open({
                    component: 'iconModal',
                    resolve: {
                        title: () => $filter('t')(`Archive By Date`),
                        paragraphs: () => [
                            $filter('t')(
                                `Are You Sure That You Wish To Archive By Date?`,
                            ),
                        ],
                        icon: () => this.warningIcon,
                        closeLabel: () => $filter('t')('Yes'),
                        dismissLabel: () => $filter('t')('No'),
                    },
                    windowClass: 'pivot_theme',
                    backdrop: 'static',
                    keyboard: false,
                });
                try {
                    const DateResponse = await DateModal.result;
                    archiveBefore(archiveDate);
                } catch (error) {
                    return null;
                }
                break;
            }
            default:
                return null;
        }
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
    this.openModal = confirmModal;
}
