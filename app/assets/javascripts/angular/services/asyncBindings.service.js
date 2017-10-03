(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('asyncBindingsService', asyncBindingsService);

    function asyncBindingsService ($injector, $q, _) {
        return {
            // This function decorator takes a resolve function and returns a new resolve function that will not block
            // the transition
            lazyLoadedResolve: function (resolve) {
                var dependencies = $injector.annotate(resolve);
                return dependencies.concat([function () {
                    // Extract the resolve function if the resolve uses inline array annotation
                    var resolveFn = _.isArray(resolve) ? _.last(resolve) : resolve;

                    // Return the original resolve value wrapped in an object. Because this object is not promise, this
                    // the will not block the transition, even if the wrapped value is a promise.
                    return { wrapped: resolveFn.apply(null, arguments) };
                }]);
            },

            // This function decorator takes a controller activate function and returns a new activate function that
            // waits for lazy loaded resolves before calling the original activate function
            lazyLoadedActivate: function (activate, bindingNames) {
                return function preactivate () {
                    var vm = this;

                    var resolvePromises = bindingNames.map(function (bindingName) {
                        // If the resolve was decorated by lazyLoadedResolve, then we need to unwrap the binding value
                        // to get the real value
                        var bindingValue = vm[bindingName];
                        var unwrappedValue = (bindingValue && bindingValue.wrapped) ?
                            bindingValue.wrapped :
                            bindingValue;

                        // Wait for the binding value to resolve if it is a promise
                        return $q.when(unwrappedValue).then(function (value) {
                            // Replace the binding with the resolved value
                            vm[bindingName] = value;
                        });
                    });

                    // Wait for all lazy loaded bindings to resolve
                    $q.all(resolvePromises).then(function () {
                        vm.ready = true;

                        // Now call the original activate
                        activate.call(vm);
                    });
                };
            }
        };
    }
})();
