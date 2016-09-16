(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('person', {
            controller: personController,
            templateUrl: '/assets/angular/components/person/person.html',
            bindings: {
                person: '<',
                organizationId: '<',
                period: '<',
                myPersonId: '<',
                onArchive: '&',
                onNewInteraction: '&'
            }
        });

    function personController ($animate, $log, $scope, peopleService, JsonApiDataStore, _) {
        var vm = this;

        vm.addInteractionBtnsVisible = false;
        vm.closingInteractionButtons = false;
        vm.interactionTypes = [
            {
                id: 2,
                icon: 'spiritualConversation',
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
                icon: 'note',
                title: 'application.interaction_types.comment'
            },
            {
                id: -1,
                icon: 'archive',
                title: 'general.archive'
            }
        ];

        vm.toggleInteractionBtns = toggleInteractionBtns;
        vm.openAddInteractionPanel = openAddInteractionPanel;
        vm.saveInteraction = saveInteraction;
        vm.reportInteractions = reportInteractions;

        vm.$onInit = activate;
        vm.$onChanges = bindingChanges;


        function activate () {
            closeAddInteractionPanel();

            // This person is considered uncontacted if their organizational permission for this organization
            // has a follow-up status of uncontacted
            var organizationalPermission = _.find(vm.person.organizational_permissions, {
                organization_id: vm.organizationId
            });
            vm.uncontacted = organizationalPermission && organizationalPermission.followup_status === 'uncontacted';
        }

        function bindingChanges (changesObj) {
            if (changesObj.period) {
                updateReport();
            }
        }

        function updateReport () {
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

        function toggleInteractionBtns () {
            vm.addInteractionBtnsVisible = !vm.addInteractionBtnsVisible;
            if (!vm.addInteractionBtnsVisible) {
                $animate.on('leave', angular.element('.addInteractionButtons'),
                    function callback (element, phase) {
                        vm.closingInteractionButtons = phase === 'start';
                        $scope.$apply();
                    }
                );
                closeAddInteractionPanel();
            }
        }

        function openAddInteractionPanel (type) {
            if(type.id == -1) {
                vm.onArchive({ person: vm.person });
            }
            else {
                vm.openPanelType = type;
            }
        }

        function saveInteraction () {
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

            var promise = peopleService.saveInteraction(createJson);
            promise.then(function () {
                $log.log('posted interaction successfully');
                vm.onNewInteraction({interaction_type_id: vm.openPanelType.id});
                vm.uncontacted = false;
                toggleInteractionBtns();
            },
            function (error) {
                $log.error('Error saving interaction', error);
            });
        }

        function closeAddInteractionPanel () {
            vm.openPanelType = '';
            vm.interactionComment = '';
        }

        function reportInteractions (interaction_type_id) {
            var interaction = _.find(vm.report.interactions, {interaction_type_id: interaction_type_id});
            return angular.isDefined(interaction) ? interaction.interaction_count : '-';
        }
    }
})();
