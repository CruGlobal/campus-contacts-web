import template from './app.html';
import './components/navigation/navHeader.component';
import './app.scss';

angular.module('campusContactsApp').component('app', {
  controller: appController,
  template,
  bindings: {
    hideHeader: '<',
    hideFooter: '<',
    hideMenuLinks: '<',
  },
});

function appController(periodService, $rootScope, analyticsService) {
  let deregisterEditOrganizationsEvent;
  let deregisterStateChangedEvent;

  this.editOrganizations = false;
  this.getPeriod = periodService.getPeriod;

  this.$onInit = () => {
    this.year = new Date();

    deregisterStateChangedEvent = $rootScope.$on('state:changed', (event, { loggedIn }) => {
      if (loggedIn) analyticsService.setupAuthenitcatedAnalyticData();
      else analyticsService.clearAuthenticatedData();
    });

    deregisterEditOrganizationsEvent = $rootScope.$on('editOrganizations', (event, value) => {
      this.editOrganizations = value;
    });
  };

  this.$onDestroy = () => {
    deregisterEditOrganizationsEvent();
    deregisterStateChangedEvent();
  };
}
