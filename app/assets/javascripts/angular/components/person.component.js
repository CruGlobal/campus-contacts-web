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

    function personController($timeout, $animate) {
        var vm = this;

        vm.addInteractionBtnsVisible = false;
        vm.openPanelName = '';
        vm.closingInteractionButtons = false;

        vm.toggleInteractionBtns = toggleInteractionBtns;
        vm.openAddInteractionPanel = openAddInteractionPanel;
        vm.closeAddInteractionPanel = closeAddInteractionPanel;

        activate();

        function activate() {

        }

        function toggleInteractionBtns(){
            vm.addInteractionBtnsVisible = !vm.addInteractionBtnsVisible;
            if(!vm.addInteractionBtnsVisible) {
                $animate.on('leave', angular.element('.addInteractionButtons'),
                    function callback(element, phase) {
                        vm.closingInteractionButtons = phase === 'start';
                    }
                );
                closeAddInteractionPanel();
            }
        }

        function openAddInteractionPanel(type){
            vm.openPanelName = type;
        }

        function closeAddInteractionPanel(){
            vm.openPanelName = '';
        }
    }
})();
