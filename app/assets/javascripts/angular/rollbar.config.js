(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .config(function (rollbar, rollbarAccessToken, envServiceProvider, $provide, _) {
            var rollbarConfig = {
                accessToken: rollbarAccessToken,
                captureUncaught: true,
                captureUnhandledRejections: false,
                environment: envServiceProvider.get(),
                enabled: !envServiceProvider.is('development') // Disable rollbar in development environment
            };
            var Rollbar = rollbar.init(rollbarConfig);

            $provide.decorator('$log', function ($delegate) {
                // Add rollbar functionality to each $log method
                angular.forEach(['log', 'debug', 'info', 'warn', 'error'], function (ngLogLevel) {
                    var rollbarLogLevel = ngLogLevel === 'warn' ? 'warning' : ngLogLevel;

                    var originalFunction = $delegate[ngLogLevel]; // Call below to keep angular $log functionality

                    $delegate[ngLogLevel] = function () {
                        originalFunction.apply(null, arguments);

                        var origin = arguments[0] && arguments[0].stack ? '$ExceptionHandler' : '$log';
                        var message = arguments[0] && arguments[0].message + '\n' +

                            // Join $log arguments
                            _.map(
                                arguments,
                                function (arg) {
                                    // Mask Auth header if present
                                    _.update(arg, 'config.headers.Authorization', function (val) {
                                        // eslint-disable-next-line no-undefined
                                        return val ? '***' : undefined;
                                    });
                                    return angular.toJson(arg, true);
                                }
                            ).join('\n');

                        Rollbar[rollbarLogLevel](message, { origin: origin });
                    };

                    // copy properties of original $log function which specs use
                    _.defaults($delegate[ngLogLevel], originalFunction);
                });

                return $delegate;
            });

            $provide.value('updateRollbarPerson', function (person) {
                Rollbar.configure({
                    payload: {
                        person: {
                            id: person.user.id,
                            person_id: person.id,
                            username: person.full_name,
                            email: person.user.username,
                            primary_organization_id: person.user.primary_organization_id
                        }
                    }
                });
            });
        });
})();
