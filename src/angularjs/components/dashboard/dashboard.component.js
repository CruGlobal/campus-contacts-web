import template from './dashboard.html';

angular.module('missionhubApp').component('dashboard', {
  controller: DashboardController,
  template: template,
});

function DashboardController(
  loggedInPerson,
  periodService,
  $uibModal,
  $rootScope,
) {
  const vm = this;
  let deregisterEditOrganizationsEvent;

  vm.editOrganizations = false;
  vm.getPeriod = periodService.getPeriod;
  vm.loggedInPerson = loggedInPerson;
  vm.$onInit = activate;
  vm.$onDestroy = deactivate;

  function activate() {
    loggedInPerson.loadOnce().then(function(me) {
      if (me.user.beta_mode === null) {
        $uibModal.open({
          component: 'newWelcomeModal',
          resolve: {},
          windowClass: 'pivot_theme',
          size: 'sm',
        });
      }
    });

    deregisterEditOrganizationsEvent = $rootScope.$on(
      'editOrganizations',
      function(event, value) {
        vm.editOrganizations = value;
      },
    );
  }

  function deactivate() {
    deregisterEditOrganizationsEvent();
  }
}
