/**
 * Created by eijeh on 8/31/16.
 */
(function () {

    'use strict';

    angular
        .module('missionhubApp')
        .factory('httpProxy', proxyService);


    function proxyService ($http, $log, $q, envService, JsonApiDataStore, _) {
        // Extract and return the data portion of a JSON API payload
        function extractData (response) {
            return response.data;
        }

        var proxy = {

            callHttp: function (method, url, params, data) {
                var config = {
                    method: method,
                    url: envService.read('apiUrl') + url,
                    data: data,
                    params: params
                };

                return $http(config).then(function (res) {
                    return JsonApiDataStore.store.syncWithMeta(res.data);
                }).catch(function (error) {
                    //We can redirect to some error page if that's better
                    $log.error(error + " - Something has gone terribly wrong.");
                    throw error;
                });
            },

            get: function (url, params) {
                return this.callHttp("GET", url, params);
            },

            post: function (url, params, data) {
                return this.callHttp("POST", url, params, data);
            },

            put: function (url, params, data) {
                return this.callHttp("PUT", url, params, data);
            },

            delete: function (url, params) {
                return this.callHttp("DELETE", url, params);
            },

            // Extract the model(s) from a JSON API response
            // These methods are intended to be used as the "then" callback in the promise returned by callHttp, e.g.
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
                    var relationshipParts = relationshipPath.split('.');
                    var relationshipHead = _.head(relationshipParts);
                    var relationshipTail = _.tail(relationshipParts);

                    // Try to find an an unloaded model
                    // If an unloaded model is found, this relationship will pass the filter and will be considered
                    // to be a unloaded relationship
                    return _.find(model[relationshipHead], function (item) {
                        return !proxy.isLoaded(
                            // If the relationship path consisted of multiple parts, reach into the item to pull out
                            // the right property
                            relationshipTail.length > 0 ? _.get(item, relationshipTail, null) : item
                        );
                    });
                });
            },

            // Return a promise that resolves to the model of the specified type and with the specified id
            // If the model is already loaded, it is returned (wrapped in a promise) without a network request
            // If the model's required relationships are not fully loaded, those are loaded as well
            getModel: function (url, type, id, relationships, requestParams) {
                var model = JsonApiDataStore.store.find(type, id);
                var unloadedRelationships = proxy.getUnloadedRelationships(model, relationships);
                return $q.resolve().then(function () {
                    if (proxy.isLoaded(model) && unloadedRelationships.length === 0) {
                        // All of the necessary data is already loaded
                        return;
                    }

                    // Load the required relationships
                    return proxy.callHttp('GET', url, _.extend({
                        include: unloadedRelationships.join(',')
                    }, requestParams));
                }).then(function () {
                    return JsonApiDataStore.store.find(type, id);
                });
            }
        }


        return proxy;
    }

})();
