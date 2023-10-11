import template from './myOrganizationsDashboard.html';
import './myOrganizationsDashboard.scss';

angular.module('campusContactsApp').component('myOrganizationsDashboard', {
  template,
  controller: function ($state) {
    this.$state = $state;
  },
});
