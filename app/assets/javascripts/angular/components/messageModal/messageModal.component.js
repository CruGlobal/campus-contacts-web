import './messageModal.scss';
import i18next from 'i18next';

import template from './messageModal.html';

angular.module('campusContactsApp').component('messageModal', {
  controller: messageModalController,
  template,
  bindings: {
    resolve: '<',
    close: '&',
    dismiss: '&',
  },
});

function messageModalController($filter, JsonApiDataStore, messageModalService, _) {
  const vm = this;

  vm.message = '';
  vm.sending = false;

  vm.getMaximumLength = getMaximumLength;
  vm.getRemainingLength = getRemainingLength;
  vm.isValid = isValid;
  vm.send = send;
  vm.cancel = cancel;

  vm.$onInit = activate;

  // The maximum message lengths of the supported media
  const lengthLimits = {
    email: 5000,
    sms: 480,
  };

  function activate() {
    vm.medium = vm.resolve.medium;
    if (!_.includes(['email', 'sms'], vm.medium)) {
      throw new Error('Invalid medium: ' + vm.medium);
    }

    vm.title = 'messages.' + vm.medium + '_title';
    vm.subtitle = 'messages.' + vm.medium + '_subtitle';
    vm.formattedRecipients = getFormattedRecipients();
  }

  // Return the recipients list as a nicely-formatted, human-readable string
  function getFormattedRecipients() {
    const filters = vm.resolve.selection.filters;
    const parts = [];

    parts.push(
      i18next.t('messages.recipients.contacts', {
        contact_count: vm.resolve.selection.totalSelectedPeople,
      }),
    );

    const organizationName = JsonApiDataStore.store.find('organization', vm.resolve.selection.orgId).name;
    parts.push(
      i18next.t('messages.recipients.organization', {
        name: organizationName,
      }),
    );

    if (filters.searchString) {
      parts.push(
        i18next.t('messages.recipients.search', {
          search: filters.searchString,
        }),
      );
    }

    const exclusions = vm.resolve.selection.allSelected ? vm.resolve.selection.unselectedPeople : [];

    /*
     * "name" the property on the filters object
     * "type" is the JSON API model type that the filter ids refer to
     * "nameField" is the name of the name attribute on the JSON API model
     * "ids" is the array of model ids and defaults to filters[definition.name]
     */
    const filterDefinitions = [
      { name: 'groups', type: 'group', nameField: 'name' },
      { name: 'labels', type: 'label', nameField: 'name' },
      { name: 'assignedTos', type: 'person', nameField: 'full_name' },
      {
        name: 'exclusions',
        type: 'person',
        nameField: 'full_name',
        ids: exclusions,
      },
    ];
    filterDefinitions.forEach(function (definition) {
      const ids = definition.ids || filters[definition.name] || [];
      if (ids.length > 0) {
        const names = ids
          .map(function (id) {
            return JsonApiDataStore.store.find(definition.type, id)[definition.nameField];
          })
          .join(', ');
        parts.push(
          i18next.t('messages.recipients.' + _.snakeCase(definition.name), {
            names,
          }),
        );
      }
    });

    return parts.join(' ');
  }

  // Return the number of characters that the message can still hold
  function getMaximumLength() {
    return lengthLimits[vm.medium];
  }

  // Return the number of characters that the message can still hold
  function getRemainingLength() {
    return getMaximumLength() - vm.message.length;
  }

  function isValid() {
    return vm.message && (vm.medium !== 'email' || vm.subject);
  }

  function send() {
    vm.sending = true;

    const sendingPromise = messageModalService.sendMessage({
      recipients: vm.resolve.selection,
      medium: vm.medium,
      subject: vm.subject,
      message: vm.message,
      surveyId: vm.resolve.surveyId,
    });

    sendingPromise.then(vm.close).catch(function () {
      vm.sending = false;
    });
  }

  function cancel() {
    vm.dismiss();
  }
}
