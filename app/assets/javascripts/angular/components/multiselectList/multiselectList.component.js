(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('multiselectList', {
            controller: multiselectListController,
            bindings: {
                // list of objects that have an id and name
                options: '=',

                // dictionary with id keys and value of true/false
                originalSelection: '=',
                addedOutput: '=',
                removedOutput: '='
            },
            templateUrl: '/assets/angular/components/multiselectList/multiselectList.html'
        });

    function multiselectListController (_) {
        var vm = this;

        vm.toggle = toggle;

        vm.$onInit = activate;

        function activate () {
            fillSelected();

            vm.addedOutput = vm.addedOutput || [];
            vm.removedOutput = vm.removedOutput || [];
        }

        function fillSelected () {
            vm.selected = _.clone(vm.originalSelection);
        }

        function toggle (id) {
            vm.selected[id] = !vm.selected[id];

            if (vm.selected[id]) {
                _.pull(vm.removedOutput, id);

                // don't add to added diff if it was one of the original selections
                if (vm.originalSelection[id] !== true) {
                    vm.addedOutput.push(id);
                }
            } else {
                _.pull(vm.addedOutput, id);

                // don't flag something to be removed if it wasn't there in the first place
                if (vm.originalSelection[id] === true) {
                    vm.removedOutput.push(id);
                }
            }
        }
    }
})();
