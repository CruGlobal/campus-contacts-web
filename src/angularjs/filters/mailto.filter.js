/*
 * The mailto filter takes an email address and converts it into a mailto link.
 * ng-href="{{ $ctrl.address | mailto }}" is superior to ng-href="mailto:{{ $ctrl.address }}" because of how it
 * handles falsy values. When given a falsy email address, the first form causes the href attribute to not be set
 * whereas the second form causes the href attribute to be set to the invalid link "mailto:" and styled as a link
 * even though it really is not.
 */
angular.module('missionhubApp').filter('mailto', function() {
  return function(address) {
    return address ? 'mailto:' + address : null;
  };
});
