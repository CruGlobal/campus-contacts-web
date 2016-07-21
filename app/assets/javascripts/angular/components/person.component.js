(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('person', {
            controller: personController,
            templateUrl: '/templates/person.html',
            bindings: {
                person: '<',
                organizationId: '<',
                period: '<',
                myPersonId: '<'
            }
        });

    function personController($animate, $http, $log, $scope, envService, JsonApiDataStore, _) {
        var vm = this;

        vm.addInteractionBtnsVisible = false;
        vm.closingInteractionButtons = false;
        vm.interactionTypes = [
            {
                id: 2,
                icon: 'free_breakfast',
                title: 'application.interaction_types.spiritual_conversation'
            },
            {
                id: 3,
                icon: 'evangelism',
                title: 'application.interaction_types.gospel_presentation'
            },
            {
                id: 4,
                icon: 'personalDecision',
                title: 'application.interaction_types.prayed_to_receive_christ'
            },
            {
                id: 5,
                icon: 'holySpirit',
                title: 'application.interaction_types.holy_spirit_presentation'
            },
            {
                id: 9,
                icon: 'discipleship',
                title: 'application.interaction_types.discipleship'
            },
            {
                id: 1,
                icon: 'event_note',
                title: 'application.interaction_types.comment'
            }
        ];

        vm.toggleInteractionBtns = toggleInteractionBtns;
        vm.openAddInteractionPanel = openAddInteractionPanel;
        vm.saveInteraction = saveInteraction;
        vm.reportInteractions = reportInteractions;

        vm.$onInit = activate;
        vm.$onChanges = bindingChanges;


        function activate() {
            closeAddInteractionPanel();
        }

        function bindingChanges(changesObj) {
            if (changesObj.period) {
                updateReport();
            }
        }

        function updateReport() {
            var id = [vm.organizationId, vm.person.id, vm.period].join('-');
            vm.report = JsonApiDataStore.store.find('person_report', id);
            if (vm.report === null) {
                vm.report = JsonApiDataStore.store.sync({
                    data: [{
                        type: 'person_report',
                        id: id,
                        attributes: {interactions: []}
                    }]
                })[0];
            }
        }

        function toggleInteractionBtns() {
            vm.addInteractionBtnsVisible = !vm.addInteractionBtnsVisible;
            if (!vm.addInteractionBtnsVisible) {
                $animate.on('leave', angular.element('.addInteractionButtons'),
                    function callback(element, phase) {
                        vm.closingInteractionButtons = phase === 'start';
                        $scope.$apply();
                    }
                );
                closeAddInteractionPanel();
            }
        }

        function openAddInteractionPanel(type) {
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
                            data: {id: vm.organizationId, type: 'organization'}
                        },
                        receiver: {
                            data: {id: vm.person.id, type: 'person'}
                        }
                    }
                }
            });
            var createJson = newInteraction.serialize();
            createJson.included = [{
                type: 'interaction_initiator',
                attributes: {
                    person_id: vm.myPersonId
                }
            }];
            $http
                .post(envService.read('apiUrl') + '/interactions', createJson)
                .then(function () {
                        $log.log('posted interaction successfully');
                        closeAddInteractionPanel();
                    },
                    function (error) {
                        $log.error('Error saving interaction', error);
                    });
        }

        function closeAddInteractionPanel() {
            vm.openPanelType = '';
            vm.interactionComment = '';
        }

        function reportInteractions(interaction_type_id) {
            var interaction = _.find(vm.report.interactions, {interaction_type_id: interaction_type_id});
            return angular.isDefined(interaction) ? interaction.interaction_count : '-';
        }
    }
})();
