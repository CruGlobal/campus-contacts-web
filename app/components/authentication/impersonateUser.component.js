import template from './impersonateUser.html';

angular.module('missionhubApp').component('impersonateUser', {
    controller: impersonatePersonController,
    template: template,
    bindings: {
        userId: '<',
    },
});

function impersonatePersonController(authenticationService, $state, $scope) {
    this.$onInit = async () => {
        if (!authenticationService.isTokenValid()) $state.go('app.people');

        this.userId
            ? await authenticationService.impersonateUser(this.userId)
            : await authenticationService.stopImpersonatingUser();

        $scope.$apply();

        $state.go('app.people');
    };
}
