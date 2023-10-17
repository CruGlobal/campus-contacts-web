// Copied from https://gist.github.com/thomseddon/4703968
angular.module('campusContactsApp').directive('autoGrow', function ($document) {
  function link(scope, element) {
    const minHeight = element[0].offsetHeight;
    const paddingLeft = element.css('paddingLeft');
    const paddingRight = element.css('paddingRight');

    const $shadow = angular.element('<div></div>').css({
      position: 'absolute',
      top: -10000,
      left: -10000,
      width: element[0].offsetWidth - parseInt(paddingLeft || 0, 10) - parseInt(paddingRight || 0, 10),
      fontSize: element.css('fontSize'),
      fontFamily: element.css('fontFamily'),
      lineHeight: element.css('lineHeight'),
      resize: 'none',
    });
    angular.element($document[0].body).append($shadow);

    function update() {
      function times(string, number) {
        let r = '';
        for (let i = 0; i < number; i++) {
          r += string;
        }
        return r;
      }

      const val = element
        .val()
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/&/g, '&amp;')
        .replace(/\n$/, '<br/>&nbsp;')
        .replace(/\n/g, '<br/>')
        .replace(/\s{2,}/g, function (space) {
          return times('&nbsp;', space.length - 1) + ' ';
        });
      $shadow.html(val);

      const threshold = 10;
      element.css('height', Math.max($shadow[0].offsetHeight + threshold, minHeight) + 'px');
    }

    scope.$on('$destroy', function () {
      $shadow.remove();
    });

    element.bind('keyup keydown keypress change', update);
    update();
  }

  return {
    link,
    restrict: 'AC',
  };
});
