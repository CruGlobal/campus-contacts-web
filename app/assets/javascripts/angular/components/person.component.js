(function(){
    'use strict';

    angular
        .module('missionhubApp')
        .component('person', {
            controller: personController,
            templateUrl: '/templates/person.html',
            bindings: {
                'person': '<'
            }
        });

    function personController() {
        // var vm = this;

        activate();

        function activate() {

        }
    }
})();
