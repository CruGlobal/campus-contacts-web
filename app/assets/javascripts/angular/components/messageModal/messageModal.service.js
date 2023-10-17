angular.module('campusContactsApp').factory('messageModalService', messageModalService);

function messageModalService(httpProxy, personSelectionService) {
  const messageModalService = {
    sendMessage: function (options) {
      const selection = options.recipients;
      const filters = personSelectionService.convertToFilters(selection, options.surveyId);

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
              recipient_ids: filters.ids,
            },
          },
          filters,
        },
        {
          errorMessage: 'error.messages.bulk_message_modal.send_message',
        },
      );
    },
  };

  return messageModalService;
}
