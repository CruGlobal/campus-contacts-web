angular
    .module('missionhubApp')
    .directive('onClickAway', function ($window, $parse, $timeout) {
        return {
            restrict: 'A',
            link: function (scope, element, attrs) {
                // Click event that added this directive to the DOM may still be propagating
                // so wait a digest cycle to add the listener
                $timeout(function () {
                    $window.addEventListener('click', handleClick);
                });

                scope.$on('$destroy', function () {
                    $window.removeEventListener('click', handleClick);
                });

                function handleClick (e) {
                    // Call the onClickAway expression when the click was not on a child of the directive's element
                    if (!element[0].contains(e.target)) {
                        scope.$apply(attrs.onClickAway);
                    }
                }
            }
        };
    });
