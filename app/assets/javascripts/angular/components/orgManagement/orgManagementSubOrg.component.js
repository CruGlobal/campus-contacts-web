import template from './orgManagementSubOrg.html';

import addIcon from '../../../../images/icons/icon-add.svg';
import editIcon from '../../../../images/icons/icon-edit.svg';
import trashIcon from '../../../../images/icons/icon-trash-blue.svg';

angular.module('missionhubApp').component('orgManagementSubOrg', {
    controller: orgManagementSubOrgController,
    bindings: {
        org: '<',
        isRoot: '<',
    },
    template: template,
});

function orgManagementSubOrgController(
    organizationOverviewSuborgsService,
    organizationService,
    confirmModalService,
    tFilter,
    $timeout,
) {
    this.addIcon = addIcon;
    this.editIcon = editIcon;
    this.trashIcon = trashIcon;

    this.orgExpanded = {};
    this.editExpanded = {};
    this.newExpanded = {};

    this.$onInit = () => {
        if (this.isRoot) {
            this.subOrgs = [this.org];
            this.orgExpanded[this.org.id] = true;
        } else {
            organizationOverviewSuborgsService
                .loadOrgSubOrgs(this.org)
                .then(subOrgs => {
                    this.subOrgs = subOrgs;
                });
        }
    };

    this.editSubOrg = ($event, orgId) => {
        $event.stopPropagation();
        this.editExpanded[orgId] = !this.editExpanded[orgId];
        this.newExpanded[orgId] = false;
    };

    this.newSubOrg = ($event, orgId) => {
        $event.stopPropagation();
        this.editExpanded[orgId] = false;
        this.newExpanded[orgId] = !this.newExpanded[orgId];
    };

    this.editComplete = (orgId, refresh) => {
        this.editExpanded[orgId] = false;
        this.newExpanded[orgId] = false;

        if (refresh) {
            this.orgExpanded[orgId] = false;
            $timeout(() => {
                this.orgExpanded[orgId] = true;
            }, 500);
        }
    };

    this.deleteSubOrg = ($event, org) => {
        $event.stopPropagation();

        if (!org) {
            return;
        }

        confirmModalService
            .create(
                tFilter('ministries:organizations.delete.confirm', {
                    org_name: org.name,
                }),
            )
            .then(() => {
                organizationService.deleteOrg(org).then(() => {
                    this.subOrgs.splice(this.subOrgs.indexOf(org), 1);
                });
            });
    };
}
