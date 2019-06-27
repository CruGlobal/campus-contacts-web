import './messageModal.scss';
import { t } from 'i18next';

import template from './messageModal.html';

angular.module('missionhubApp').component('messageModal', {
    controller: messageModalController,
    template: template,
    bindings: {
        resolve: '<',
        close: '&',
        dismiss: '&',
    },
});

function messageModalController(
    $filter,
    JsonApiDataStore,
    messageModalService,
    _,
) {
    var vm = this;

    vm.message = '';
    vm.sending = false;

    vm.getMaximumLength = getMaximumLength;
    vm.getRemainingLength = getRemainingLength;
    vm.isValid = isValid;
    vm.send = send;
    vm.cancel = cancel;

    vm.$onInit = activate;

    // The maximum message lengths of the supported media
    var lengthLimits = {
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
        var filters = vm.resolve.selection.filters;
        var parts = [];

        parts.push(
            t('messages.recipients.contacts', {
                contact_count: vm.resolve.selection.totalSelectedPeople,
            }),
        );

        var organizationName = JsonApiDataStore.store.find(
            'organization',
            vm.resolve.selection.orgId,
        ).name;
        parts.push(
            t('messages.recipients.organization', { name: organizationName }),
        );

        if (filters.searchString) {
            parts.push(
                t('messages.recipients.search', {
                    search: filters.searchString,
                }),
            );
        }

        var exclusions = vm.resolve.selection.allSelected
            ? vm.resolve.selection.unselectedPeople
            : [];

        /*
         * "name" the property on the filters object
         * "type" is the JSON API model type that the filter ids refer to
         * "nameField" is the name of the name attribute on the JSON API model
         * "ids" is the array of model ids and defaults to filters[definition.name]
         */
        var filterDefinitions = [
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
        filterDefinitions.forEach(function(definition) {
            var ids = definition.ids || filters[definition.name] || [];
            if (ids.length > 0) {
                var names = ids
                    .map(function(id) {
                        return JsonApiDataStore.store.find(
                            definition.type,
                            id,
                        )[definition.nameField];
                    })
                    .join(', ');
                parts.push(
                    t('messages.recipients.' + _.snakeCase(definition.name), {
                        names: names,
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

        var sendingPromise = messageModalService.sendMessage({
            recipients: vm.resolve.selection,
            medium: vm.medium,
            subject: vm.subject,
            message: vm.message,
            surveyId: vm.resolve.surveyId,
        });

        sendingPromise.then(vm.close).catch(function() {
            vm.sending = false;
        });
    }

    function cancel() {
        vm.dismiss();
    }
}
