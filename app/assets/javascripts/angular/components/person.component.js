(function(){
    'use strict';

    angular
        .module('missionhubApp')
        .component('person', {
            controller: personController,
            templateUrl: '/templates/person.html',
            bindings: {
                'person': '<',
                'organizationId': '<'
            }
        });

    function personController($animate, $http, $log, envService, JsonApiDataStore) {
        var vm = this;

        vm.addInteractionBtnsVisible = false;
        vm.closingInteractionButtons = false;

        vm.toggleInteractionBtns = toggleInteractionBtns;
        vm.openAddInteractionPanel = openAddInteractionPanel;
        vm.saveInteraction = saveInteraction;

        vm.interactionTypes = [
            {id: 2, icon: 'free_breakfast', title: 'Spiritual Conversation'},
            {id: 3, icon: 'multiline_chart', title: 'Personal Evangelism'},
            {id: 4, icon: 'spa', title: 'Personal Evangelism Decisions'},
            {id: 5, icon: 'whatshot', title: 'Holy Spirit Presentation'},
            {id: 9, icon: 'free_breakfast', title: 'Discipleship / Leadership'},
            {id: 1, icon: 'event_note', title: 'Comment Only'}
        ];

        activate();

        function activate() {
            closeAddInteractionPanel()
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
            vm.openPanelType = type;
        }

        function saveInteraction() {
            var newInteraction = JsonApiDataStore.store.sync({
                data: {
                    type: 'interaction',
                    attributes: {
                        comment: vm.interactionComment,
                        interaction_type_id: vm.openPanelType.id
                    },
                    relationships: {
                        organization: {
                            data: { id: vm.organizationId, type: 'organization' }
                        },
                        receiver: {
                            data: { id: vm.person.id, type: 'person' }
                        }
                    }
                }
            });
            $log.log(newInteraction);
            $http
                .post(envService.read('apiUrl') + '/interactions', newInteraction.serialize())
                .then(function() {
                        $log.log('posted interaction successfully');
                        closeAddInteractionPanel();
                    },
                    function(error){
                        $log.error('Error saving interaction', error);
                    });
        }

        function closeAddInteractionPanel(){
            vm.openPanelType = '';
            vm.interactionComment = '';
        }
    }
})();
