import template from './organization.html';
import './organization.scss';

angular.module('campusContactsApp').component('organization', {
  controller: organizationController,
  bindings: {
    options: '<?',
    collapsed: '<?',
    collapsible: '<?',
    editMode: '<',
    org: '<',
  },
  template,
  transclude: true,
});

function organizationController($rootScope, loggedInPerson, interactionsService, userPreferencesService, _) {
  const vm = this;

  vm.$onInit = activate;
  vm.$onDestroy = deactivate;

  vm.addAnonymousInteractionButtonsVisible = false;
  vm.pendingAnonymousInteraction = null;

  // Restrict to the interactions that can be anonymous
  vm.anonymousInteractionTypes = _.filter(interactionsService.getInteractionTypes(), { anonymous: true });

  vm.toggleAnonymousInteractionButtons = toggleAnonymousInteractionButtons;
  vm.toggleVisibility = toggleVisibility;
  vm.addAnonymousInteraction = addAnonymousInteraction;
  vm.saveAnonymousInteraction = saveAnonymousInteraction;

  let unsubscribe;

  function activate() {
    _.defaultsDeep(vm, {
      collapsed: false,
      collapsible: false,
      options: {
        anonymousInteractions: false,
        reorderable: false,
      },
    });

    // Add new people assigned to the logged-in user to this org's people list
    unsubscribe = $rootScope.$on('personCreated', function (event, person) {
      if (
        _.find(person.reverse_contact_assignments, {
          assigned_to: loggedInPerson.person,
        })
      ) {
        vm.org.people.push(person);
      }
    });
  }

  function deactivate() {
    unsubscribe();
  }

  function toggleAnonymousInteractionButtons() {
    vm.addAnonymousInteractionButtonsVisible = !vm.addAnonymousInteractionButtonsVisible;
    if (!vm.addAnonymousInteractionButtonsVisible) {
      closeAnonymousInteractions();
    }
  }

  function closeAnonymousInteractions() {
    vm.addAnonymousInteractionButtonsVisible = false;
    vm.pendingAnonymousInteraction = null;
  }

  function addAnonymousInteraction(type) {
    vm.pendingAnonymousInteraction = {
      type,
      comment: '',
    };
  }

  function saveAnonymousInteraction() {
    const interaction = {
      interactionTypeId: vm.pendingAnonymousInteraction.type.id,
      comment: vm.pendingAnonymousInteraction.comment,
    };
    interactionsService.recordInteraction(interaction, vm.org.id, null).then(function () {
      closeAnonymousInteractions();
    });
  }

  function toggleVisibility() {
    userPreferencesService.toggleOrganizationVisibility(vm.org);
  }
}
