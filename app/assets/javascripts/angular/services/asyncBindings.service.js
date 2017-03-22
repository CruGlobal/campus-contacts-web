(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('asyncBindingsService', asyncBindingsService);

    function asyncBindingsService ($q) {
        return {
            // When a state's resolvePolicy.await is set to NOWAIT, all of its resolves will come back as promises. This
            // method takes a component instance and a list of the names of those bindings, and replaces the promise
            // values on that instance with the resolved values after each one resolves. It returns a promise that will
            // resolve when all of the bindings have resolved.
            resolveAsyncBindings: function (vm, bindingNames) { // eslint-disable-line consistent-this
                var resolvePromises = bindingNames.map(function (bindingName) {
                    return $q.when(vm[bindingName]).then(function (value) {
                        // Replace the binding with the resolved value
                        vm[bindingName] = value;
                    });
                });

                // Wait for all bindings to resolve
                return $q.all(resolvePromises);
            }
        };
    }
})();
