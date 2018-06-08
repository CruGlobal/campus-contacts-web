import template from './loadingSpinner.html';
import './loadingSpinner.scss';

angular.module('missionhubApp').component('loadingSpinner', {
  bindings: {
    size: '<',
  },
  template: template,
});
