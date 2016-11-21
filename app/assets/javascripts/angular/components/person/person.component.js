(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('person', {
            controller: personController,
            templateUrl: '/assets/angular/components/person/person.html',
            bindings: {
                person: '<',
                organizationId: '<'
            }
        });

    function personController ($animate, $filter, $scope, confirm, jQuery,
                               periodService, personService, reportsService, interactionsService) {
        var vm = this;

        vm.addInteractionBtnsVisible = false;
        vm.closingInteractionButtons = false;
        vm.interactionTypes = interactionsService.getInteractionTypes().concat({
            id: -1,
            icon: 'archive',
            title: 'general.archive'
        });

        vm.toggleInteractionBtns = toggleInteractionBtns;
        vm.openAddInteractionPanel = openAddInteractionPanel;
        vm.saveInteraction = saveInteraction;
        vm.reportInteractions = reportInteractions;

        vm.$onInit = activate;

        function activate () {
            closeAddInteractionPanel();

            vm.uncontacted = personService.getFollowupStatus(vm.person, vm.organizationId) === 'uncontacted';

            periodService.subscribe($scope, lookupReport);
            lookupReport();
        }

        function lookupReport () {
            vm.report = reportsService.lookupPersonReport(vm.organizationId, vm.person.id);
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
            if (type.id === -1) {
                archivePerson();
            } else {
                vm.openPanelType = type;
            }
        }

        function saveInteraction () {
            var interaction = { interactionTypeId: vm.openPanelType.id, comment: vm.interactionComment };
            interactionsService.recordInteraction(interaction, vm.organizationId, vm.person.id).then(function () {
                vm.uncontacted = false;
                toggleInteractionBtns();
            });
        }

        function closeAddInteractionPanel () {
            vm.openPanelType = '';
            vm.interactionComment = '';
        }

        function reportInteractions (interactionTypeId) {
            return reportsService.getInteractionCount(vm.report, interactionTypeId);
        }

        function archivePerson () {
            var really = confirm($filter('t')('organizations.cleanup.confirm_archive'));
            if (!really) {
                return;
            }
            personService.archivePerson(vm.person, vm.organizationId)
                .catch(function () {
                    jQuery.e($filter('t')('dashboard.error_archiving_person'));
                });
        }
    }
})();
