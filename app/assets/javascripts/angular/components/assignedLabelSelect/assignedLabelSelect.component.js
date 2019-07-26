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
    this.originalLabels = [];
    this.$onInit = () => {
        // When this loads, get all the labels and set this.originalLabels to all the labels. We do this once instead of every time the user types.
        assignedLabelSelectService
            .searchLabels(this.organizationId)
            .then(labels => {
                this.originalLabels = labels;
            });
        // This will happen everytime the user types
        $scope.$watch('$select.search', search => {
            if (search === '') {
                // Set this.labels to the original list of labels we fetched
                this.labels = [...this.originalLabels];
                return;
            }
            // Here we filter out all the labels from the originalLabels array that do not include what the user is currently typing
            this.labels = this.originalLabels.filter(label =>
                label.name.toLowerCase().includes(search.toLowerCase()),
            );
        });

        $scope.$watch('$ctrl.assigned', (o, n) => {
            if (this.actionAfterSelect && o !== n) {
                this.actionAfterSelect();
            }
        });
    };
}
