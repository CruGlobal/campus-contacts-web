angular
    .module('missionhubApp')
    .factory('transferService', transferService);

function transferService (httpProxy, JsonApiDataStore, personSelectionService) {
    return {
        // Transfer the contacts in the selection to the specified organization
        transfer: function (selection, org, options) {
            var filters = personSelectionService.convertToFilters(selection);

            var bulkTransfer = new JsonApiDataStore.Model('bulk_transfer');
            bulkTransfer.setAttribute('person_ids', filters.ids);
            bulkTransfer.setAttribute('from_organization_id', selection.orgId);
            bulkTransfer.setAttribute('to_organization_id', org.id);
            bulkTransfer.setAttribute('keep_copy', options.copyContact);
            bulkTransfer.setAttribute('copy_answer_sheets', options.copyAnswers);
            bulkTransfer.setAttribute('copy_interactions', options.copyInteractions);

            return httpProxy.post(
                '/bulk_transfers',
                {
                    data: bulkTransfer.serialize().data,
                    filters: filters
                },
                {
                    errorMessage: 'error.messages.bulk_transfer_modal.transfer_contacts'
                }
            );
        }
    };
}
