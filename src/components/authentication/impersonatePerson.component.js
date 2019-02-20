import template from './impersonatePerson.html';

angular.module('missionhubApp').component('impersonatePerson', {
    controller: impersonatePersonController,
    template: template,
    bindings: {
        userId: '<',
    },
});

function impersonatePersonController(authenticationService, $state, $scope) {
    this.$onInit = async () => {
        if (!authenticationService.isTokenValid()) $state.go('app.people');

        if (this.userId)
            await authenticationService.impersonatePerson(this.userId);
        else await authenticationService.stopImpersonatingPerson();

        $scope.$apply();

        $state.go('app.people');
    };
}
