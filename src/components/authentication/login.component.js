import template from './login.html';
import './login.scss';

angular.module('missionhubApp').component('login', {
    controller: loginController,
    template: template,
});

function loginController(envService) {
    this.$onInit = () => {
        this.url = envService.read('railsUrl');
    };
}
