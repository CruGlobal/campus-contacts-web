import template from './orgManagementEdit.html';

import helpIcon from '../../../../images/icons/icon-help.svg';

angular.module('missionhubApp').component('orgManagementEdit', {
    controller: orgManagementEditController,
    bindings: {
        org: '<',
        new: '<',
        editComplete: '&',
    },
    template: template,
});

function orgManagementEditController(organizationService) {
    this.helpIcon = helpIcon;

    this.$onInit = () => {
        if (this.new) {
            this.orgEdit = {
                show_sub_orgs: true,
            };
        } else {
            this.orgEdit = { ...this.org };
        }
    };

    this.save = () => {
        if (this.new) {
            organizationService.createOrg(this.orgEdit, this.org).then(() => {
                this.editComplete({ orgId: this.org.id, refresh: true });
            });
        } else {
            organizationService.saveOrg(this.orgEdit).then(() => {
                this.org = this.orgEdit;

                this.editComplete({ orgId: this.org.id });
            });
        }
    };
}
