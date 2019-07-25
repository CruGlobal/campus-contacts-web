import template from './assignedLabelSelect.html';
import './assignedLabelSelect.scss';

angular.module('missionhubApp').component('assignedLabelSelect', {
    bindings: {
        assigned: '=',
        organizationId: '<',
        disabled: '<',
        actionAfterSelect: '&',
    },
    controller: assignedLabelSelectController,
    template: template,
});

function assignedLabelSelectController($scope, assignedLabelSelectService) {
    this.labels = [];
    this.$onInit = () => {
        // Refresh the person list whenever the search term changes
        $scope.$watch('$select.search', search => {
            if (search === '') {
                // Ignore empty searches
                this.labels = [];
                return;
            }

            assignedLabelSelectService
                .searchLabels(search, this.organizationId)
                .then(labels => {
                    if (search === undefined) {
                        labels.map(label => {
                            this.labels = [...this.labels, label];
                        });
                    } else if (search !== undefined) {
                        labels.map(label => {
                            if (
                                label.name
                                    .toLowerCase()
                                    .includes(search.toLowerCase())
                            ) {
                                this.labels = [...this.labels, label];
                            }
                        });
                    }
                });
        });

        $scope.$watch('$ctrl.assigned', (o, n) => {
            if (this.actionAfterSelect && o !== n) {
                this.actionAfterSelect();
            }
        });
    };
}
