import template from './impersonatePerson.html';

angular.module('missionhubApp').component('impersonatePerson', {
    controller: impersonatePersonController,
    template: template,
    bindings: {
        personId: '<',
    },
});

function impersonatePersonController(authenticationService, $state) {
    this.$onInit = async () => {
        if (!authenticationService.isTokenValid() || !this.personId)
            $state.go('app.people');

        await authenticationService.impersonatePerson();

        $state.go('app.people');
    };
}
