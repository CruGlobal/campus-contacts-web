import template from './navHeader.html';

angular.module('missionhubApp').component('navHeader', {
    controller: navHeaderController,
    template: template,
});

function navHeaderController(state, loggedInPerson, $timeout) {
    this.$onInit = () => {
        this.state = state;
        this.railsUrl = envService.read('railsUrl');

        $timeout(() => {
            this.loggedInPerson = loggedInPerson;
        });
    };
}
