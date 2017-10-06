(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .config(function (rollbar, rollbarAccessToken, StackTrace, envServiceProvider, $provide, _) {
            var rollbarConfig = {
                accessToken: rollbarAccessToken,
                captureUncaught: true,
                captureUnhandledRejections: false,
                environment: envServiceProvider.get(),
                enabled: !envServiceProvider.is('development'), // Disable rollbar in development environment
                transform: transformRollbarPayload,
                payload: {
                    client: {
                        javascript: {
                            source_map_enabled: true,
                            guess_uncaught_frames: true
                        }
                    }
                }
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
                        var stackFramesPromise, message;

                        if (origin === '$ExceptionHandler') {
                            message = arguments[0].message;

                            // Parse the exception to get the stack
                            stackFramesPromise = StackTrace.fromError(arguments[0], { offline: true });
                        } else {
                            if (arguments[0] && (arguments[0].status === -1 || arguments[0].status === 401)) {
                                return; // Drop browser network errors and unauthorized api errors due to expired tokens
                            }

                            // Join $log arguments
                            message = arguments[0] && arguments[0].message + '\n' +
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

                            // Log came from app so we get the stacktrace from this file
                            stackFramesPromise = StackTrace.get({ offline: true });
                        }

                        stackFramesPromise
                            .then(function (stackFrames) {
                                // For logs, ignore first stack frame which is this file
                                if (origin === '$log') {
                                    stackFrames.shift();
                                }

                                // Send combined message and stack trace to rollbar
                                Rollbar[rollbarLogLevel](message, { stackTrace: stackFrames, origin: origin });
                            })
                            .catch(function (error) {
                                // Send message without stack trace to rollbar
                                Rollbar[rollbarLogLevel](message, { origin: origin });

                                // Send warning about the issue loading stackframes
                                Rollbar.warning('Error loading stackframes: ' + error);
                            });
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

            function transformRollbarPayload (payload) {
                if (_.get(payload, 'body.message.extra.stackTrace')) {
                    // Convert message format to trace format
                    payload.body.trace = {
                        frames: formatStacktraceForRollbar(payload.body.message.extra.stackTrace),
                        exception: {
                            message: payload.body.message.body,
                            class: payload.body.message.extra.origin
                        }
                    };
                    delete payload.body.message;
                }
                return payload;
            }

            function formatStacktraceForRollbar (stackFrames) {
                return _.map(stackFrames, function (frame) {
                    return {
                        method: frame.functionName,
                        lineno: frame.lineNumber,
                        colno: frame.columnNumber,
                        filename: frame.fileName
                    };
                });
            }
        });
})();
