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

    function organizationController (JsonApiDataStore, loggedInPerson, periodService,
                                     reportsService, interactionsService, myPeopleDashboardService, _) {
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

        vm.toggleAnonymousInteractionButtons = toggleAnonymousInteractionButtons;
        vm.toggleVisibility = toggleVisibility;
        vm.addAnonymousInteraction = addAnonymousInteraction;
        vm.saveAnonymousInteraction = saveAnonymousInteraction;

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
                closeAnonymousInteractions();
            });
        }

        function toggleVisibility () {
            myPeopleDashboardService.toggleOrganizationVisibility(vm.org);
        }
    }
})();
