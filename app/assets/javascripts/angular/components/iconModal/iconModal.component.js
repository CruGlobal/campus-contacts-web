import template from './iconModal.html';
import './iconModal.scss';

angular.module('campusContactsApp').component('iconModal', {
  template,
  bindings: {
    resolve: '<',
    close: '&',
    dismiss: '&',
  },
});
