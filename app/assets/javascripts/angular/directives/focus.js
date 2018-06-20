// This directive focuses the element if the "focus" attribute is truthy.
angular.module('missionhubApp').directive('focus', function() {
    return {
        restrict: 'A',
        scope: { focus: '<' },
        link: function(scope, element) {
            if (scope.focus) {
                element[0].focus();
            }
        },
    };
});
