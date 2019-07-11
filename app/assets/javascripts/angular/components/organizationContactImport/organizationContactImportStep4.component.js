import checkIcon from '../../../../images/icons/icon-check.svg';

import template from './organizationContactImportStep4.html';

angular.module('missionhubApp').component('organizationContactImportStep4', {
    bindings: {
        org: '<',
    },
    template: template,
    controller: organizationContactImportStep4Controller,
});

function organizationContactImportStep4Controller() {
    this.checkIcon = checkIcon;
}
