import template from './navSearch.html';
import './navSearch.scss';

angular.module('campusContactsApp').component('navSearch', {
  controller: navSearchController,
  template,
});

function navSearchController(peopleSearchService) {
  this.$onInit = () => {
    this.searchPeople = peopleSearchService.search;
  };
}
