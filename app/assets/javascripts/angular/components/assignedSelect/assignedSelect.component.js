import template from './assignedSelect.html';
import './assignedSelect.scss';

angular.module('missionhubApp').component('assignedSelect', {
    bindings: {
        assigned: '=',
        organizationId: '<',
        disabled: '<',
        actionAfterSelect: '&',
    },
    controller: assignedSelectController,
    template: template,
});

function assignedSelectController(
    $scope,
    assignedSelectService,
    RequestDeduper,
) {
    var vm = this;
    vm.people = [];
    vm.labels = [];
    vm.isMe = assignedSelectService.isMe;
    vm.$onInit = activate;

    function activate() {
        var requestDeduper = new RequestDeduper();

        // Refresh the person list whenever the search term changes
        $scope.$watch('$select.search', function(search) {
            if (search === '') {
                // Ignore empty searches
                vm.people = [];
                vm.labels = [];
                return;
            }

            assignedSelectService
                .searchPeople(search, vm.organizationId, requestDeduper)
                .then(function(people) {
                    vm.people = people;
                })
                .then(() => {
                    assignedSelectService
                        .searchLabels(search, vm.organizationId)
                        .then(labels => {
                            vm.labels = labels;
                            if (search === undefined) {
                                labels.map(label => {
                                    vm.people = [...vm.people, label];
                                });
                            } else if (search !== undefined) {
                                labels.map(label => {
                                    if (
                                        label.name
                                            .toLowerCase()
                                            .includes(search.toLowerCase())
                                    ) {
                                        vm.people = [...vm.people, label];
                                    }
                                });
                            }
                        });
                });
        });

        $scope.$watch('$ctrl.assigned', (o, n) => {
            if (vm.actionAfterSelect && o !== n) {
                vm.actionAfterSelect();
            }
        });
    }
}
