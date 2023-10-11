import template from './loadingSpinner.html';
import './loadingSpinner.scss';

angular.module('campusContactsApp').component('loadingSpinner', {
  bindings: {
    size: '<',
  },
  template,
});
