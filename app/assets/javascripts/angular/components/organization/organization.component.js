(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('organization', {
            controller: organizationController,
            bindings: {
                options: '<?',
                collapsed: '<?',
                collapsible: '<?',
                editMode: '<',
                org: '<'
            },
            templateUrl: '/assets/angular/components/organization/organization.html',
            transclude: true
        });

    function organizationController ($scope, JsonApiDataStore, loggedInPerson, periodService,
                                     reportsService, interactionsService, organizationService,
                                     myContactsDashboardService, _) {
        var vm = this;

        _.defaultsDeep(vm, {
            collapsed: false,
            collapsible: false,
            options: {
                anonymousInteractions: false,
                reorderable: false
            }
        });

        vm.addAnonymousInteractionButtonsVisible = false;
        vm.pendingAnonymousInteraction = null;
        // Restrict to the interactions that can be anonymous
        vm.anonymousInteractionTypes = _.filter(interactionsService.getInteractionTypes(), { anonymous: true });

        vm.$onInit = activate;
        vm.toggleAnonymousInteractionButtons = toggleAnonymousInteractionButtons;
        vm.toggleVisibility = toggleVisibility;
        vm.addAnonymousInteraction = addAnonymousInteraction;
        vm.saveAnonymousInteraction = saveAnonymousInteraction;

        function activate () {
            // Listen for new interactions from the person child components
            $scope.$on('newInteraction', function (event, interactionId) {
                organizationService.incrementReportInteraction(vm.report, interactionId);
            });
        }

        function toggleAnonymousInteractionButtons () {
            vm.addAnonymousInteractionButtonsVisible = !vm.addAnonymousInteractionButtonsVisible;
            if (!vm.addAnonymousInteractionButtonsVisible) {
                closeAnonymousInteractions();
            }
        }

        function closeAnonymousInteractions () {
            vm.addAnonymousInteractionButtonsVisible = false;
            vm.pendingAnonymousInteraction = null;
        }

        function addAnonymousInteraction (type) {
            vm.pendingAnonymousInteraction = {
                type: type,
                comment: ''
            };
        }

        function saveAnonymousInteraction () {
            var interaction = {
                interactionTypeId: vm.pendingAnonymousInteraction.type.id,
                comment: vm.pendingAnonymousInteraction.comment
            };
            interactionsService.recordInteraction(interaction, vm.org.id, null).then(function () {
                $scope.$emit('newInteraction', interaction.id);
                closeAnonymousInteractions();
            });
        }

        function toggleVisibility () {
            myContactsDashboardService.toggleOrganizationVisibility(vm.org);
        }
    }
})();
