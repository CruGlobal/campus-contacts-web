import template from './navSearch.html';
import './navSearch.scss';

angular.module('missionhubApp').component('navSearch', {
    controller: navSearchController,
    template: template,
});

function navSearchController(peopleSearchService) {
    this.$onInit = () => {
        this.searchPeople = peopleSearchService.search;
    };
}
