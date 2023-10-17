import './errorRetryToastTemplate.directive';

angular.module('campusContactsApp').factory('errorService', errorService);

function errorService($timeout, $q, $log, toaster, _) {
  const errorService = {
    displayError,
    autoRetry,

    // Default retry configuration for network requests
    networkRetryConfig: {
      retryDelay: 1000,

      retryFilter: function (err) {
        // Retry network errors and 500 errors
        return err.status === -1 || err.status === 500;
      },
    },
  };

  // Display UI that informs the user about an error that occurred and allows them to retry the failed operation
  // if it is retryable
  // Return a promise that will resolve when the user chooses to retry the operation and reject with the
  // original error if the user chooses not to retry
  function displayError(err, retryable) {
    return new $q(function (resolve, reject) {
      if (!retryable) {
        // We don't need to wait to find out whether the user will retry the operation
        reject(err);
      }

      // No popup for logged out needed
      if (err.status === 401) {
        resolve();
        return;
      }

      toaster.pop({
        title: 'Error',
        body: 'error-retry-toast-template',
        bodyOutputType: 'directive',
        directiveData: {
          error: err,
          retryable,
        },
        type: 'error',

        // Never automatically dismiss retryable prompts
        timeout: retryable ? 0 : 10000,

        // Retry when the toast is clicked
        clickHandler: function (toast, isCloseButton) {
          if (!isCloseButton) {
            resolve();
          }

          // Remove the toast
          return true;
        },

        // Reject when the toast is closed
        onHideCallback: function () {
          reject(err);
        },
      });
    });
  }

  // This function decorator wraps a function that returns a promise in a function that will retry errors
  function autoRetry(getPromise, rawOptions) {
    const options = _.defaults(rawOptions, {
      // Retry once
      retryCount: 1,

      // Retry immediately
      retryDelay: 0,

      // Retry all errors
      retryFilter: _.constant(true),

      // Ignore no errors
      ignoreFilter: _.constant(false),
    });

    // Return the wrapper function that decorates the original getPromise function
    return function wrapped() {
      let retriesRemaining = options.retryCount;

      // This error handler determines whether an error should be retried and retries the failed operation if
      // necessary
      function possiblyRetryError(err) {
        const ignore = options.ignoreFilter(err);
        if (ignore) {
          // Ignore the error; don't show an error message for it and don't retry it
          throw err;
        }

        // Stop retrying if we are out of retries or the filter says to not retry this error
        const retryable = options.retryFilter(err);
        if (retriesRemaining === 0 || !retryable) {
          $log.error(err);

          // Wait for the user to manually initiate a retry, then try again
          return errorService.displayError(err, retryable).then(attempt);
        }

        // Wait out the delay, then try again
        retriesRemaining--;
        return $timeout(options.retryDelay).then(attempt);
      }

      const originalContext = this; // eslint-disable-line consistent-this
      const originalArgs = arguments;

      function attempt() {
        // Take all of the arguments passed to the wrapper function and pass them to the original function
        return getPromise.apply(originalContext, originalArgs).catch(possiblyRetryError);
      }

      return attempt();
    };
  }

  return errorService;
}
