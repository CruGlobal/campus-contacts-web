angular
  .module('missionhubApp')
  .factory('mergeWinnerService', mergeWinnerService);

function mergeWinnerService(httpProxy, modelsService, dateFilter, _) {
  var mergeWinnerService = {
    // The fields of a choice.person object
    personFields: [
      'first_name',
      'last_name',
      'gender',
      'email_addresses',
      'phone_numbers',
      'created_date',
      'updated_date',
    ],

    // The fields of a choice.user object
    userFields: [
      'id',
      'username',
      'created_date',
      'updated_date',
      'login_date',
    ],

    // Generate a choice object from a person model
    choiceFromPersonModel: function(model) {
      var dateFormat = 'MM/dd/yyyy HH:mm:ss';
      var person = {
        first_name: model.first_name,
        last_name: model.last_name,
        gender: model.gender,
        email_addresses: _.map(model.email_addresses, 'email').join(', '),
        phone_numbers: _.map(model.phone_numbers, 'number').join(', '),
        created_date: dateFilter(model.created_at, dateFormat),
        updated_date: dateFilter(model.updated_at, dateFormat),
      };

      var user = model.user && {
        id: model.user.id,
        username: model.user.username,
        created_date: dateFilter(model.user.created_at, dateFormat),
        updated_date: dateFilter(model.user.updated_at, dateFormat),
        login_date: dateFilter(model.user.last_sign_in_at, dateFormat),
      };

      return {
        model: model,
        person: person,
        user: user,
      };
    },

    // Given an array of person ids, return a promise that resolves to an array of choice objects
    generateChoices: function(personIds) {
      // Load the people's user relationships
      return httpProxy
        .get(
          modelsService.getModelMetadata('person').url.all,
          {
            'filters[ids]': personIds.join(','),
            included: 'user',
          },
          {
            errorMessage: 'error.messages.merge_winner.load_users',
          },
        )
        .then(httpProxy.extractModels)
        .then(function(people) {
          return people.map(mergeWinnerService.choiceFromPersonModel);
        });
    },
  };

  return mergeWinnerService;
}
