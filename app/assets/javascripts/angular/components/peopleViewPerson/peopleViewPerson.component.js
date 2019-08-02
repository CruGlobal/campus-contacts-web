import template from './peopleViewPerson.html';
import './peopleViewPerson.scss';

angular.module('missionhubApp').component('peopleViewPerson', {
    controller: peopleViewPersonController,
    template: template,
    bindings: {
        person: '<',
        organizationId: '<',
    },
});

function peopleViewPersonController(
    $animate,
    $filter,
    $scope,
    confirm,
    $state,
    periodService,
    personService,
    reportsService,
    interactionsService,
) {
    var vm = this;

    vm.addInteractionBtnsVisible = false;
    vm.closingInteractionButtons = false;
    vm.toggleInteractionBtns = toggleInteractionBtns;
    vm.openAddInteractionPanel = openAddInteractionPanel;
    vm.saveInteraction = saveInteraction;
    vm.reportInteractions = reportInteractions;
    vm.openProfile = openProfile;
    vm.$onInit = activate;

    function activate() {
        vm.interactionTypes = interactionsService.getInteractionTypes().concat({
            id: -1,
            icon: 'archive',
            title: 'general.archive',
        });
        closeAddInteractionPanel();

        vm.uncontacted =
            personService.getFollowupStatus(vm.person, vm.organizationId) ===
            'uncontacted';

        periodService.subscribe($scope, lookupReport);
        lookupReport();
    }

    function lookupReport() {
        vm.report = reportsService.lookupPersonReport(
            vm.organizationId,
            vm.person.id,
        );
    }

    function toggleInteractionBtns() {
        vm.addInteractionBtnsVisible = !vm.addInteractionBtnsVisible;
        if (!vm.addInteractionBtnsVisible) {
            $animate.on(
                'leave',
                angular.element('.addInteractionButtons'),
                function callback(element, phase) {
                    vm.closingInteractionButtons = phase === 'start';
                    $scope.$apply();
                },
            );
            closeAddInteractionPanel();
        }
    }

    function openAddInteractionPanel(type) {
        if (type.id === -1) {
            archivePerson();
        } else {
            vm.openPanelType = type;
        }
    }

    function saveInteraction() {
        var interaction = {
            interactionTypeId: vm.openPanelType.id,
            comment: vm.interactionComment,
        };
        interactionsService
            .recordInteraction(interaction, vm.organizationId, vm.person.id)
            .then(function() {
                vm.uncontacted = false;
                toggleInteractionBtns();
            });
    }

    function closeAddInteractionPanel() {
        vm.openPanelType = '';
        vm.interactionComment = '';
    }

    function reportInteractions(interactionTypeId) {
        return reportsService.getInteractionCount(vm.report, interactionTypeId);
    }

    function archivePerson() {
        var really = confirm(
            $filter('t')('organizations.cleanup.confirm_archive'),
        );
        if (!really) {
            return;
        }
        personService.archivePerson(vm.person, vm.organizationId);
    }

    // Open the profile page for this person
    function openProfile() {
        $state.go('.person.defaultTab', {
            personId: vm.person.id,
            orgId: vm.organizationId,
        });
    }
}
