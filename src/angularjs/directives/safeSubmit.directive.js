// ng-safe-submit is similar to ng-submit except that it automatically prevents double-submissions. The
// ng-safe-submit event handler can return a promise. If it does, the form is disabled until the promise resolves.
angular.module('missionhubApp').directive('ngSafeSubmit', function($q, _) {
  return {
    restrict: 'A',
    scope: { ngSafeSubmit: '&' },
    link: function(scope, element) {
      // Set the enabled status of the form
      function setFormEnabled(enabled) {
        // Update the form enabled status by enabling/disabling the submit button if present
        _.each(element.find('button'), function(button) {
          if (button.type === 'submit') {
            button.disabled = !enabled;
          }
        });
      }

      var submissionPending = false;
      element.on('submit', function(event) {
        if (submissionPending) {
          // A submission is in progress, so ignore this form submission
          return false;
        }

        // Disable the form
        submissionPending = true;
        setFormEnabled(false);

        scope.$apply(function() {
          // Call the submission event handler
          var submissionPromise = scope.ngSafeSubmit(scope, { $event: event });

          // After the promise returned by the submission handler resolves,enable the form again
          $q.resolve(submissionPromise).then(function() {
            submissionPending = false;
            setFormEnabled(true);
          });
        });
      });
    },
  };
});
