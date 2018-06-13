import template from './app.html';
import './app.scss';

angular.module('missionhubApp').component('app', {
  controller: appController,
  template: template,
});

function appController() {
  const vm = this;
}
