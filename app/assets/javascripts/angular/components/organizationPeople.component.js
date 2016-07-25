(function () {
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
                'people': '<',
                'period': '<',
                'myPersonId': '<',
                'editMode': '<'
            }
        });

    function organizationPeopleController ($log, $http, envService, JsonApiDataStore, lscache, _) {
        var vm = this,
            UNASSIGNED_VISIBLE = 'unassignedVisible';

        vm.addAnonymousInteractionButtonsVisible = false;
        vm.anonymousInteractionTypes = [
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
            }
        ];


        vm.reportInteractions = reportInteractions;
        vm.setUnassignedVisible = setUnassignedVisible;
        vm.toggleAnonymousInteractionButtons = toggleAnonymousInteractionButtons;
        vm.addAnonymousInteraction = addAnonymousInteraction;
        vm.saveAnonymousInteraction = saveAnonymousInteraction;

        vm.$onInit = activate;
        vm.$onChanges = bindingsChanged;

        function activate () {
            var key = [UNASSIGNED_VISIBLE, vm.id].join(':'),
                val = lscache.get(key);
            vm.unassignedVisible = (val === null) ? true : val;
        }

        function bindingsChanged (changesObj) {
            if (changesObj.period) {
                loadReport();
            }
        }

        function loadReport () {
            var id = [vm.id, vm.period].join('-');
            vm.report = JsonApiDataStore.store.find('organization_report', id);
            if (vm.report === null) {
                vm.report = JsonApiDataStore.store.sync({
                    data: [{
                        type: 'organization_report',
                        id: id,
                        attributes: {interactions: []}
                    }]
                })[0];
            }
        }

        function reportInteractions (interaction_type_id) {
            var interaction = _.find(vm.report.interactions, {interaction_type_id: interaction_type_id});
            return angular.isDefined(interaction) ? interaction.interaction_count : '-';
        }

        function setUnassignedVisible (value) {
            var key = [UNASSIGNED_VISIBLE, vm.id].join(':');
            vm.unassignedVisible = !!value;
            lscache.set(key, vm.unassignedVisible, 24 * 60); // 24 hour expiry
        }

        function toggleAnonymousInteractionButtons () {
            vm.addAnonymousInteractionButtonsVisible = !vm.addAnonymousInteractionButtonsVisible;
            if (!vm.addAnonymousInteractionButtonsVisible) {
                closeAnonymousInteractions();
            }
        }

        function addAnonymousInteraction (type) {
            vm.addAnonymousInteractionType = type;
        }

        function saveAnonymousInteraction () {
            if (angular.isUndefined(vm.addAnonymousInteractionType)) { return }

            var newInteraction = JsonApiDataStore.store.sync({
                data: {
                    type: 'interaction',
                    attributes: {
                        comment: vm.anonymousInteractionComment,
                        interaction_type_id: vm.addAnonymousInteractionType.id
                    },
                    relationships: {
                        organization: {
                            data: {id: vm.id, type: 'organization'}
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
                        incrementReportInteraction(vm.addAnonymousInteractionType.id);
                        closeAnonymousInteractions();
                    },
                    function (error) {
                        $log.error('Error saving interaction', error);
                    });
        }

        function closeAnonymousInteractions () {
            vm.addAnonymousInteractionButtonsVisible = false;
            delete vm.addAnonymousInteractionType;
            delete vm.anonymousInteractionComment;
        }

        function incrementReportInteraction (interaction_type_id) {
            var interaction = _.find(vm.report.interactions, {interaction_type_id: interaction_type_id});
            if (angular.isDefined(interaction)) {
                interaction.interaction_count++;
            } else {
                vm.report.interactions.push({interaction_type_id: interaction_type_id, interaction_count: 1});
            }
        }
    }
})();
