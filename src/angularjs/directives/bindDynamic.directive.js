// Inspired by http://stackoverflow.com/a/21445567
angular.module('missionhubApp').directive('bindDynamic', [
  '$compile',
  function($compile) {
    return {
      restrict: 'A',
      replace: true,
      scope: { bindDynamic: '=' },
      link: function(scope, element) {
        scope.$watch('bindDynamic', function(html) {
          element.html(html);
          $compile(element.contents())(scope);
        });
      },
    };
  },
]);
