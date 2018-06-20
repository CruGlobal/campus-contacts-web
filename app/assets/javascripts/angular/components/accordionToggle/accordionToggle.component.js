import template from './accordionToggle.html';
import './accordionToggle.scss';

angular.module('missionhubApp').component('accordionToggle', {
    controller: accordionToggleController,
    require: {
        accordion: '^',
    },
    template: template,
});

function accordionToggleController() {
    var vm = this;

    vm.toggleVisibility = toggleVisibility;

    function toggleVisibility() {
        vm.accordion.collapsed = !vm.accordion.collapsed;
    }
}
