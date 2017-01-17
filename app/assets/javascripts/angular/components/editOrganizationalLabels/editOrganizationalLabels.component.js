(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('editOrganizationalLabels', {
            controller: editOrganizationalLabelsController,
            bindings: {
                resolve: '<',
                close: '&',
                dismiss: '&'
            },
            templateUrl: '/assets/angular/components/editOrganizationalLabels/editOrganizationalLabels.html'
        });

    function editOrganizationalLabelsController (editOrganizationalLabelsService, JsonApiDataStore, _) {
        var vm = this;

        vm.title = 'people.index.manage_labels';
        vm.saving = false;
        vm.labelOptions = [];
        vm.selectedLabels = {};

        vm.save = save;
        vm.cancel = cancel;

        vm.$onInit = activate;

        function activate () {
            loadLabelOptions();
        }

        function loadLabelOptions () {
            var labels = JsonApiDataStore.store.find('organization', vm.resolve.organizationId).labels;
            vm.labelOptions = _.sortBy(labels, function (organization) {
                return parseInt(organization.id, 10);
            });
            vm.selectedLabels = _.chain(vm.resolve.person.organizational_labels)
                .filter({ organization_id: vm.resolve.organizationId })
                .map(function (orgLabel) {
                    return [orgLabel.label.id, true];
                })
                .fromPairs()
                .value();
        }

        function save () {
            vm.saving = true;
            var savingPromise = editOrganizationalLabelsService.saveOrganizationLabels(vm.resolve.person,
                vm.selectedLabels,
                vm.resolve.organizationId);

            savingPromise
                .then(vm.close)
                .catch(function () {
                    vm.saving = false;
                });
        }

        function cancel () {
            vm.dismiss();
        }
    }
})();
