import template from './asyncContent.html';
import './asyncContent.scss';

angular.module('campusContactsApp').component('asyncContent', {
  bindings: {
    ready: '<',
  },
  template,
  transclude: true,
});
