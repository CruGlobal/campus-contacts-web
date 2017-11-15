angular
    .module('missionhubApp')
    .factory('messageModalService', messageModalService);

function messageModalService (httpProxy, personSelectionService) {
    var messageModalService = {
        sendMessage: function (options) {
            var selection = options.recipients;
            var filters = personSelectionService.convertToFilters(selection);

            return httpProxy.post(
                '/bulk_messages',
                {
                    data: {
                        type: 'bulk_message',
                        attributes: {
                            organization_id: selection.orgId,
                            send_via: options.medium,
                            subject: options.subject,
                            message: options.message,

                            // Prefer using recipient_ids over filters because the former does validation that the
                            // latter does not. If recipient_ids is truthy, it will override the filters.
                            recipient_ids: filters.ids
                        }
                    },
                    filters: filters
                },
                {
                    errorMessage: 'error.messages.bulk_message_modal.send_message'
                }
            );
        }
    };

    return messageModalService;
}
