import template from './assignedAltSelect.html';
import './assignedAltSelect.scss';

angular.module('missionhubApp').component('assignedAltSelect', {
    bindings: {
        assigned: '=',
        organizationId: '<',
        disabled: '<',
        actionAfterSelect: '&',
    },
    controller: assignedAltSelectController,
    template: template,
});

function assignedAltSelectController($scope, assignedAltSelectService) {
    var vm = this;
    vm.labels = [];
    vm.isMe = assignedAltSelectService.isMe;
    vm.$onInit = activate;

    function activate() {
        // Refresh the person list whenever the search term changes
        $scope.$watch('$select.search', function(search) {
            if (search === '') {
                // Ignore empty searches
                vm.labels = [];
                return;
            }

            assignedAltSelectService
                .searchLabels(search, vm.organizationId)
                .then(labels => {
                    if (search === undefined) {
                        labels.map(label => {
                            vm.labels = [...vm.labels, label];
                        });
                    } else if (search !== undefined) {
                        labels.map(label => {
                            if (
                                label.name
                                    .toLowerCase()
                                    .includes(search.toLowerCase())
                            ) {
                                vm.labels = [...vm.labels, label];
                            }
                        });
                    }
                });
        });

        $scope.$watch('$ctrl.assigned', (o, n) => {
            if (vm.actionAfterSelect && o !== n) {
                vm.actionAfterSelect();
            }
        });
    }
}
