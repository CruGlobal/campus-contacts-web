(function(){
    'use strict';

    angular
        .module('missionhubApp')
        .component('organizationPeople', {
            controller: organizationPeopleController,
            templateUrl: '/templates/organizationPeople.html',
            bindings: {
                'id': '@',
                'name': '@',
                'collapsible': '<',
                'people': '<'
            }
        });

    function organizationPeopleController() {
        // var vm = this;

        activate();

        function activate() {

        }
    }
})();
