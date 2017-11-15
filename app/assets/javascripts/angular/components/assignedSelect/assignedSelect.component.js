import template from './assignedSelect.html';
import './assignedSelect.scss';

angular
    .module('missionhubApp')
    .component('assignedSelect', {
        bindings: {
            assigned: '=',
            organizationId: '<'
        },
        controller: assignedSelectController,
        template: template
    });

function assignedSelectController ($scope, assignedSelectService, RequestDeduper) {
    var vm = this;
    vm.people = [];
    vm.isMe = assignedSelectService.isMe;
    vm.$onInit = activate;

    function activate () {
        var requestDeduper = new RequestDeduper();

        // Refresh the person list whenever the search term changes
        $scope.$watch('$select.search', function (search) {
            if (search === '') {
                // Ignore empty searches
                vm.people = [];
                return;
            }

            assignedSelectService.searchPeople(search, vm.organizationId, requestDeduper).then(function (people) {
                vm.people = people;
            });
        });
    }
}
