import template from './myOrganizationsDashboard.html';
import './myOrganizationsDashboard.scss';

angular.module('missionhubApp').component('myOrganizationsDashboard', {
  template: template,
  controller: function($state) {
    this.$state = $state;
  },
});
