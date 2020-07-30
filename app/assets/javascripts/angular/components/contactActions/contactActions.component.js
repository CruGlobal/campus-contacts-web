import template from './contactActions.html';
import './contactActions.scss';

angular.module('missionhubApp').component('contactActions', {
    bindings: {
        phone: '<',
        email: '<',
    },
    template: template,
    controller: contactActionsController,
});

function contactActionsController() {
    this.actionsVisible = false;

    this.toggleActions = () => {
        this.actionsVisible = !this.actionsVisible;
    };

    this.copyText = (text) => navigator.clipboard.writeText(text);
}
