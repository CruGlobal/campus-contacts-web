import template from './nav-search.html';
import './nav-search.scss';

angular.module('missionhubApp').component('navSearch', {
    controller: navSearchController,
    template: template,
});

function navSearchController(peopleSearchService) {
    this.$onInit = () => {
        this.searchPeople = peopleSearchService.search;
    };
}
