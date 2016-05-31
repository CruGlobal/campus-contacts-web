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
        var vm = this;

        vm.addInteractionBtnsVisible = false;
        vm.openPanelName = '';

        vm.toggleInteractionBtns = toggleInteractionBtns;
        vm.openAddInteractionPanel = openAddInteractionPanel;
        vm.closeAddInteractionPanel = closeAddInteractionPanel;

        activate();

        function activate() {

        }

        function toggleInteractionBtns(){
            vm.addInteractionBtnsVisible = !vm.addInteractionBtnsVisible;
            if(!vm.addInteractionBtnsVisible){
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
