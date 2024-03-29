import template from './personProfile.html';
import './personProfile.scss';

angular.module('campusContactsApp').component('personProfile', {
  controller: personProfileController,
  require: {
    personTab: '^personPage',
  },
  template,
});

function personProfileController(
  $scope,
  $filter,
  $uibModal,
  JsonApiDataStore,
  permissionService,
  personService,
  personProfileService,
  loggedInPerson,
  confirmModalService,
  _,
) {
  const vm = this;

  vm.pendingEmailAddress = null;
  vm.pendingPhoneNumber = null;
  vm.modalInstance = null;

  vm.saveAttribute = saveAttribute;
  vm.saveRelationship = saveRelationship;
  vm.isContact = isContact;
  vm.emailAddressesWithPending = emailAddressesWithPending;
  vm.phoneNumbersWithPending = phoneNumbersWithPending;
  vm.isPendingEmailAddress = isPendingEmailAddress;
  vm.isPendingPhoneNumber = isPendingPhoneNumber;
  vm.isEmailAddressValid = isEmailAddressValid;
  vm.isPhoneNumberValid = isPhoneNumberValid;
  vm.addEmailAddress = addEmailAddress;
  vm.addPhoneNumber = addPhoneNumber;
  vm.deleteEmailAddress = deleteEmailAddress;
  vm.deletePhoneNumber = deletePhoneNumber;
  vm.deleteAddress = deleteAddress;
  vm.permissionChange = permissionChange;
  vm.editTags = editTags;
  vm.editGroups = editGroups;
  vm.editAddress = editAddress;
  vm.unarchive = unarchive;
  vm.formatAddress = personProfileService.formatAddress;

  vm.$onInit = activate;
  vm.$onDestroy = onDestroy;

  vm.followupStatusOptions = personService.getFollowupStatusOptions();
  vm.cruStatusOptions = personService.getCruStatusOptions();
  vm.permissionOptions = personService.getPermissionOptions();
  vm.enrollmentOptions = personService.getEnrollmentOptions();

  function activate() {
    vm.isNewPerson = !vm.personTab.person.id;
    vm.personTab.orgPermission.permission_id = `${vm.personTab.orgPermission.permission_id}`;
    // Disable editing name fields of other users
    vm.disableNameFields = vm.personTab.person.user && loggedInPerson.person !== vm.personTab.person;

    // The personPage needs access to the profile form to determine validity. Because component "require" only
    // works upwards (from descendent to ancestor), we have to have the profile component send its profile form
    // to the person component.
    var unsubscribeForm = $scope.$watch('$ctrl.form', function (form) {
      if (form) {
        vm.personTab.profileForm = form;
        unsubscribeForm();
      }
    });

    const organization = JsonApiDataStore.store.find('organization', vm.personTab.organizationId);
    if (loggedInPerson.person === vm.personTab.person) {
      vm.permissionChangeDisabled = true;
    } else if (!loggedInPerson.isAdminAt(organization)) {
      if (`${vm.personTab.orgPermission.permission_id}` === permissionService.adminId) {
        vm.permissionChangeDisabled = true;
      } else {
        vm.permissionOptions.shift();
      }
    }

    // Save the changes on the server whenever the primary email or primary phone changes
    $scope.$watch('$ctrl.personTab.primaryEmail', updatePrimary);
    $scope.$watch('$ctrl.personTab.primaryPhone', updatePrimary);

    $scope.$watchCollection('$ctrl.personTab.assignedTo', function (newAssignedTo, oldAssignedTo) {
      if (newAssignedTo === oldAssignedTo) {
        return;
      }

      $scope.$emit('personModified');

      const addedPeople = _.difference(newAssignedTo, oldAssignedTo);
      personProfileService.addAssignments(vm.personTab.person, vm.personTab.organizationId, addedPeople);

      const removedPeople = _.difference(oldAssignedTo, newAssignedTo);
      personProfileService.removeAssignments(vm.personTab.person, removedPeople);
    });

    $scope.$watchCollection('$ctrl.personTab.person.gender', function (newGender, oldGender) {
      if (newGender !== oldGender) {
        saveAttribute(vm.personTab.person, 'gender');
      }
    });

    if (vm.personTab.options.assignToMe) {
      // Assign the person to the logged in person
      const newAssignment = loggedInPerson.person;
      vm.personTab.assignedTo.push(newAssignment);
      personProfileService.addAssignments(vm.personTab.person, vm.personTab.organizationId, [newAssignment]);
    }
  }

  function onDestroy() {
    if (vm.modalInstance) {
      vm.modalInstance.close();
    }
  }

  function updatePrimary(newPrimary, oldPrimary) {
    if (newPrimary === oldPrimary) {
      // Do nothing if the primary item is not changing
      return;
    }

    if (newPrimary && !newPrimary.primary) {
      newPrimary.primary = true;
      saveAttribute(newPrimary, 'primary');
    }

    if (oldPrimary) {
      oldPrimary.primary = false;
    }
  }

  function saveAttribute(model, attribute) {
    if (_.isUndefined(model[attribute])) {
      // The attribute is invalid, so do not attempt to auto-save it
      return;
    }

    $scope.$emit('personModified');

    // Only save the attribute if it passes validation
    const control = vm.form[attribute];
    if (!control || control.$valid) {
      personProfileService.saveAttribute(vm.personTab.person.id, model, attribute);
    }
  }

  function saveRelationship(relationship, attribute, relationshipName) {
    if (_.isUndefined(relationship[attribute])) {
      // The attribute is invalid, so do not attempt to auto-save it
      return;
    }

    $scope.$emit('personModified');

    const savePromise = personProfileService.saveRelationship(
      vm.personTab.person,
      relationship,
      relationshipName,
      attribute,
    );
    savePromise.then(function () {
      if (relationship === vm.pendingEmailAddress) {
        vm.pendingEmailAddress = null;
      } else if (relationship === vm.pendingPhoneNumber) {
        vm.pendingPhoneNumber = null;
      }
    });
  }

  function deleteRelationship(relationship, relationshipName) {
    $scope.$emit('personModified');

    personProfileService.deleteRelationship(vm.personTab.person, relationship, relationshipName);
  }

  function isContact() {
    return personService.isContact(vm.personTab.person, vm.personTab.organizationId);
  }

  function emailAddressesWithPending() {
    const emailAddresses = vm.personTab.person.email_addresses;

    if (!vm.pendingEmailAddress) {
      addEmailAddress();
      // If we add an email address, set the error to null
      vm.personTab.orgPermission.$error = null;
    }
    return emailAddresses.concat(vm.pendingEmailAddress);
  }

  function phoneNumbersWithPending() {
    const phoneNumbers = vm.personTab.person.phone_numbers;

    if (!vm.pendingPhoneNumber) {
      addPhoneNumber();
    }
    return phoneNumbers.concat(vm.pendingPhoneNumber);
  }

  function isPendingEmailAddress(emailAddress) {
    return emailAddress === vm.pendingEmailAddress;
  }

  function isPendingPhoneNumber(phoneNumber) {
    return phoneNumber === vm.pendingPhoneNumber;
  }

  function isEmailAddressValid(emailAddress) {
    const control = vm.form['email_address_' + (emailAddress.id || 'pending')];
    return control.$valid || (control.$viewValue === '' && vm.isPendingEmailAddress(emailAddress));
  }

  function isPhoneNumberValid(phoneNumber) {
    const control = vm.form['phone_number_' + (phoneNumber.id || 'pending')];
    return control.$valid || (control.$viewValue === '' && vm.isPendingPhoneNumber(phoneNumber));
  }

  // Add a new email address to the person
  // The email address is not actually saved to the server until the call to saveAttribute
  function addEmailAddress() {
    vm.pendingEmailAddress = new JsonApiDataStore.Model('email_address');
    vm.pendingEmailAddress.setAttribute('person_id', vm.personTab.person.id);
    vm.pendingEmailAddress.setAttribute('email', '');
    vm.pendingEmailAddress.setAttribute('primary', false);
    vm.pendingEmailAddress.setAttribute('$valid', true);
  }

  // Add a new phone number to the person
  // The phone number is not actually saved to the server until the call to saveAttribute
  function addPhoneNumber() {
    vm.pendingPhoneNumber = new JsonApiDataStore.Model('phone_number');
    vm.pendingPhoneNumber.setAttribute('person_id', vm.personTab.person.id);
    vm.pendingPhoneNumber.setAttribute('number', '');
    vm.pendingPhoneNumber.setAttribute('primary', false);
    vm.pendingPhoneNumber.setAttribute('$valid', true);
  }

  function deleteEmailAddress(emailAddress) {
    const message = $filter('t')('people.edit.delete_email_confirm');
    const confirmModal = confirmModalService.create(message);

    confirmModal
      .then(function () {
        deleteRelationship(emailAddress, 'email_addresses');
      })
      .then(() => {
        vm.form.email_address_pending = vm.pendingEmailAddress;
      });
  }

  function deletePhoneNumber(phoneNumber) {
    const message = $filter('t')('people.edit.delete_phone_confirm');
    const confirmModal = confirmModalService.create(message);

    confirmModal
      .then(function () {
        deleteRelationship(phoneNumber, 'phone_numbers');
      })
      .then(() => {
        vm.form.phone_number_pending = vm.pendingPhoneNumber;
      });
  }

  function deleteAddress(address) {
    const message = $filter('t')('people.edit.delete_address_confirm');
    const confirmModal = confirmModalService.create(message);

    confirmModal.then(function () {
      deleteRelationship(address, 'addresses');
    });
  }

  /*
    This is used on the profile component with a tricky interpolation that results in it
    returning the old value. It looks like this:
    ng-change="$ctrl.permissionChange({{$ctrl.personTab.orgPermission.permission_id}})"
    Reference: http://stackoverflow.com/a/28047112/879524
     */
  function permissionChange(oldValue, choice) {
    const hasEmailAddress = vm.personTab.person.email_addresses.length > 0;

    // Set the error to null everytime this run in case the user updated their email
    vm.personTab.orgPermission.$error = null;
    if (hasEmailAddress) {
      vm.saveAttribute(vm.personTab.orgPermission, 'permission_id');
      // Check is the choice the user makes is No permissions, and if so allow them to update without email
    } else if (choice === vm.permissionOptions[2].id) {
      vm.saveAttribute(vm.personTab.orgPermission, 'permission_id');
    } else {
      vm.personTab.orgPermission.permission_id = oldValue;
      // Set orgPermission $error to be the needed error message
      vm.personTab.orgPermission.$error = $filter('t')('contacts.index.for_this_permission_email_is_required_no_name');
    }
  }

  function editTags() {
    editLabelsOrGroups('organizational_labels', vm.personTab.updateLabels);
  }

  function editGroups() {
    editLabelsOrGroups('group_memberships', vm.personTab.updateGroupMemberships);
  }

  function editLabelsOrGroups(relationship, updateFunction) {
    vm.modalInstance = $uibModal.open({
      animation: true,
      component: 'editGroupOrLabelAssignments',
      resolve: {
        organizationId: function () {
          return vm.personTab.organizationId;
        },
        person: function () {
          return vm.personTab.person;
        },
        relationship: function () {
          return relationship;
        },
      },
      windowClass: 'pivot_theme',
      size: 'md',
    });

    vm.modalInstance.result
      .then(function () {
        $scope.$emit('personModified');

        updateFunction();
      })
      .finally(function () {
        vm.modalInstance = null;
      });
  }

  // Open an address for editing in a modal dialog
  function editAddress(address) {
    const addressModal = $uibModal.open({
      animation: true,
      component: 'editAddress',
      resolve: {
        organizationId: function () {
          return vm.personTab.organizationId;
        },

        person: function () {
          return vm.personTab.person;
        },

        address: function () {
          return address;
        },
      },
      windowClass: 'pivot_theme',
      size: 'md',
    });

    addressModal.result.then(function () {
      $scope.$emit('personModified');
    });
  }

  function unarchive() {
    if (vm.personTab.orgPermission !== null) {
      vm.personTab.orgPermission.archive_date = null;
      vm.saveAttribute(vm.personTab.orgPermission, 'archive_date');
    }
  }
}
