import template from './organizationContactImportStep4.html';
import checkIcon from '../../../../images/icon-check.svg';

angular.module('missionhubApp').component('organizationContactImportStep4', {
    require: {
        organizationOverview: '^',
    },
    bindings: {},
    template: template,
    controller: organizationContactImportStep4Controller,
});

function organizationContactImportStep4Controller() {
    this.checkIcon = checkIcon;
}
