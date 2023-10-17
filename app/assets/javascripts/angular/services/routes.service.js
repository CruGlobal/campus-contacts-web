angular.module('campusContactsApp').factory('routesService', routesService);

// This service contains logic used by the routes
function routesService(httpProxy, modelsService) {
  return {
    // Return a promise that resolves to the specified person in the specified organization, loading that
    // person if necessary
    getPerson: function (personId) {
      const url = modelsService.getModelMetadata('person').url.single(personId);
      return httpProxy.getModel(
        url,
        'person',
        personId,
        [
          'phone_numbers',
          'email_addresses',
          'addresses',
          'organizational_permissions',
          'organizational_labels.label',
          'group_memberships',
          'reverse_contact_assignments.assigned_to',
        ],
        {
          params: { 'filters[include_archived]': true },
          errorMessage: 'error.messages.routes.get_person',
        },
      );
    },

    // Return a promise that resolves to the specified organization, loading that organization if necessary
    getOrganization: function (organizationId) {
      const url = modelsService.getModelMetadata('organization').url.single(organizationId);
      return httpProxy.getModel(
        url,
        'organization',
        organizationId,
        ['labels', 'groups'],
        {
          errorMessage: 'error.messages.routes.get_organization',
        },
        {
          'fields[group]':
            'name,location,meets,meeting_day,start_time,end_time,list_publicly,approve_join_requests,group_memberships,organization',
        },
      );
    },

    // Load a person's interaction history (which consists of interactions as well as survey responses)
    getHistory: function (personId) {
      const url = modelsService.getModelMetadata('person').url.single(personId);
      return httpProxy.getModel(
        url,
        'person',
        personId,
        ['interactions', 'answer_sheets.answers.question', 'answer_sheets.survey'],
        {
          errorMessage: 'error.messages.routes.get_history',
        },
      );
    },

    getSurvey: function (surveyId) {
      return httpProxy.getModel(
        modelsService.getModelMetadata('survey').url.single(surveyId),
        'survey',
        surveyId,
        ['keyword'],
        {
          errorMessage: 'error.messages.routes.get_survey',
        },
      );
    },

    getPhoneNumberValidation: function (code, id) {
      return httpProxy.getModel(
        modelsService.getModelMetadata('phone_number_validation').url.single(code),
        'phone_number_validation',
        id,
        ['survey', 'phone_number'],
        {
          errorMessage: 'error.messages.routes.get_phone_number_validation',
        },
      );
    },
  };
}
