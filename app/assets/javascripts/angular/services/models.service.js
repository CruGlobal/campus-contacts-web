angular.module('campusContactsApp').factory('modelsService', modelsService);

function modelsService(_) {
  function generateUrls(root, extras) {
    return {
      // The base URL
      root,

      // The URL for a single model
      single: function (id) {
        return root + '/' + id;
      },

      // The URL for all models
      all: root,
    };
  }

  const modelMetadata = {
    person: {
      include: 'people',
      url: generateUrls('/people'),
    },
    user: {
      include: 'users',
      url: generateUrls('/users'),
    },
    email_address: {
      include: 'email_addresses',
      url: generateUrls('/email_addresses'),
    },
    phone_number: {
      include: 'phone_numbers',
      url: generateUrls('/phone_numbers'),
    },
    phone_number_validation: {
      include: 'phone_number_validations',
      url: generateUrls('/phone_numbers/validations'),
    },
    address: {
      include: 'addresses',
      url: generateUrls('/addresses'),
    },
    organization: {
      include: 'organizations',
      url: generateUrls('/organizations'),
    },
    person_report: {
      include: 'person_reports',
      url: generateUrls('/reports/people'),
    },
    organization_report: {
      include: 'organization_reports',
      url: generateUrls('/reports/organizations'),
    },
    label: {
      include: 'labels',
      url: generateUrls('/labels'),
    },
    organizational_label: {
      url: generateUrls('/organizational_labels'),
    },
    interaction: {
      include: 'interactions',
      url: generateUrls('/interactions'),
    },
    contact_assignment: {
      include: 'contact_assignments',
      url: generateUrls('/contact_assignments'),
    },
    group: {
      include: 'groups',
      url: generateUrls('/groups'),
    },
    group_membership: {
      url: generateUrls('/group_memberships'),
    },
    filter_stats: {
      url: generateUrls('/filter_stats'),
    },
    survey: {
      include: 'surveys',
      url: generateUrls('/surveys'),
    },
    sms_keyword: {
      include: 'sms_keywords',
      url: generateUrls('/sms_keywords'),
    },
    survey_report: {
      include: 'survey_reports',
      url: generateUrls('/reports/survey'),
    },
    survey_questions: {
      include: 'survey_questions',
      url: generateUrls('/survey/questions'),
    },
    bulk_create_job: {
      include: 'bulk_create_jobs',
      url: generateUrls('/answer_sheets/bulk_create_jobs'),
    },
    answer_sheet: {
      url: generateUrls('/answer_sheets'),
    },
  };

  var modelsService = {
    // Return the metadata for a particular model
    getModelMetadata: function (model) {
      return modelMetadata[model];
    },

    // Return the single URL for a model
    getModelUrl: function (model) {
      const metadata = modelsService.getModelMetadata(model._type);
      return metadata && metadata.url.single(model.id);
    },
  };

  return modelsService;
}
