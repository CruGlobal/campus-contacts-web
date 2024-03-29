import { JsonApiDataStore as JsonApiDataStoreIsolated } from 'jsonapi-datastore';

angular.module('campusContactsApp').factory('httpProxy', proxyService);
function proxyService(
  $http,
  $log,
  $q,
  envService,
  JsonApiDataStore,
  modelsService,
  Upload,
  tFilter,
  errorService,
  _,
  $injector,
  sessionStorageService,
  $window,
) {
  // Extract and return the data portion of a JSON API payload
  function extractData(response) {
    return response.data;
  }

  // Send a network request using a generic provider that uses the same API as $http.
  // This was added because Uploader.upload provides functionality on top of $http, but we
  // want to be able to reuse the authorization token, JSON API store syncing, and
  // other logic that was originally in callHttp.
  function networkRequest(provider, method, url, params, data, extraConfig) {
    function makeRequest(dedupeConfig) {
      const EXPIRED_ACCESS_TOKEN = 'Expired access token';
      const INVALID_ACCESS_TOKEN = 'Invalid access token';
      const INVALID_GRANT = 'invalid_grant';
      const MISSING_TOKEN = 'Missing access token';

      const config = {
        method,
        url: envService.read('apiUrl') + url,
        data,

        // Default value
        errorMessage: 'error.messages.http_proxy.default_network_error',

        ...extraConfig,
        params: { ...params, ...extraConfig?.params },
        ...dedupeConfig,
      };

      if (!extraConfig || !extraConfig.errorMessage) {
        $log.warn(new Error('No error message specified'));
      }

      // Angular throws a circular dependency. Happens since the authenticationService
      // also calls on another service that httpProxyService calls.
      // So only way around is the injector.
      const authenticationService = $injector.get('authenticationService');

      return provider(config)
        .then((res) => {
          // store rolling access token
          const token = res.headers('x-mh-session');

          if (token) {
            $http.defaults.headers.common.Authorization = 'Bearer ' + token;

            authenticationService.storeJwtToken(token);
          }

          if (extraConfig && extraConfig.bypassStore) {
            return new JsonApiDataStoreIsolated().syncWithMeta(res.data);
          }

          return JsonApiDataStore.store.syncWithMeta(res.data);
        })
        .catch((err) => {
          const { data } = err || {};

          if (data && data.errors && data.errors[0] && data.errors[0].detail) {
            const errorDetail = data.errors[0].detail;

            if (
              EXPIRED_ACCESS_TOKEN === errorDetail ||
              INVALID_ACCESS_TOKEN === errorDetail ||
              MISSING_TOKEN === errorDetail ||
              INVALID_GRANT === errorDetail
            ) {
              authenticationService.removeAccess();
            }
          }

          err.message = (config.showApiMessage && data?.errors?.[0]?.detail) || tFilter(config.errorMessage);
          throw err;
        });
    }

    if (extraConfig && extraConfig.deduper) {
      return extraConfig.deduper.request(makeRequest);
    }
    return makeRequest({});
  }

  var proxy = {
    callHttp: errorService.autoRetry(function (method, url, params, data, extraConfig) {
      return networkRequest($http, method, url, params, data, extraConfig);
    }, errorService.networkRetryConfig),

    submitForm: errorService.autoRetry(function (method, url, form, extraConfig) {
      return networkRequest(Upload.upload, method, url, null, form, extraConfig);
    }, errorService.networkRetryConfig),

    get: function (url, params, config) {
      return this.callHttp('GET', url, params, null, config);
    },

    post: function (url, data, config) {
      return this.callHttp('POST', url, null, data, config);
    },

    put: function (url, data, config) {
      return this.callHttp('PUT', url, null, data, config);
    },

    delete: function (url, params, config) {
      return this.callHttp('DELETE', url, params, null, config);
    },

    // Extract the model(s) from a JSON API response
    // These methods are intended to be used as the 'then' callback in the promise returned by callHttp, e.g.
    //
    //     httpProxy.get(url, params).then(httpProxy.extractModels).then(function (models) {});
    //
    // extractModel and extractModels are aliases for one another.
    extractModel: extractData,
    extractModels: extractData,

    // Determine whether a model has been loaded
    isLoaded: function (model) {
      return Boolean(model && !model._placeHolder);
    },

    // Given a model and an array of needed relationships, determine which of those relationships have not yet
    // been loaded
    getUnloadedRelationships: function (model, relationships) {
      if (!proxy.isLoaded(model)) {
        // All relationships of unloaded models and placeholder models are considered unloaded
        return relationships;
      }

      // Unloaded relationships contain unloaded models
      return relationships.filter(function (relationshipPath) {
        const relationshipParts = relationshipPath.split('.');
        const relationshipHead = _.head(relationshipParts);
        const relationshipTail = _.tail(relationshipParts);

        if (!model[relationshipHead]) {
          // The relationship is not even present on the model, and is therefore considered unloaded
          return true;
        }

        // Try to find an an unloaded model
        // If an unloaded model is found, this relationship will pass the filter and will be considered
        // to be a unloaded relationship
        return _.find(model[relationshipHead], function (item) {
          // If the relationship path consisted of multiple parts, reach into the item to pull out
          // the right property
          return !proxy.isLoaded(relationshipTail.length > 0 ? _.get(item, relationshipTail, null) : item);
        });
      });
    },

    // Return a promise that resolves to the model of the specified type and with the specified id
    // If the model is already loaded, it is returned (wrapped in a promise) without a network request
    // If the model's required relationships are not fully loaded, those are loaded as well
    getModel: function (url, type, id, relationships, extraConfig, extraParameters) {
      const model = JsonApiDataStore.store.find(type, id);
      const unloadedRelationships = proxy.getUnloadedRelationships(model, relationships);
      return $q
        .resolve()
        .then(function () {
          if (proxy.isLoaded(model) && unloadedRelationships.length === 0) {
            // All of the necessary data is already loaded
            return;
          }

          // Load the required relationships
          return proxy.get(
            url,
            {
              include: unloadedRelationships.join(','),
              ...extraParameters,
            },
            extraConfig,
          );
        })
        .then(function () {
          return JsonApiDataStore.store.find(type, id);
        });
    },

    // Return the URL for a JSON API model
    getModelUrl: function (model) {
      return modelsService.getModelMetadata(model._type).url.single(model.id);
    },

    // Generate a JSON API "included" array from an array of models
    includedFromModels: function (models) {
      return models.map(function (model) {
        // Don't send the relationships' relationships
        return model.serialize({ relationships: [] }).data;
      });
    },
  };

  return proxy;
}
