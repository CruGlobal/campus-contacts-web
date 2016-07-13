(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('organizationPeople', {
            controller: organizationPeopleController,
            templateUrl: '/templates/organizationPeople.html',
            bindings: {
                'id': '@',
                'name': '@',
                'collapsible': '<',
                'people': '<',
                'period': '<'
            }
        });

    function organizationPeopleController(JsonApiDataStore) {
        var vm = this;

        vm.reportInteractions = reportInteractions;

        vm.$onChanges = bindingsChanged;

        function bindingsChanged(changesObj) {
            if (changesObj.period) {
                loadReport();
            }
        }

        function loadReport() {
            var id = [vm.id, vm.period].join('-');
            vm.report = JsonApiDataStore.store.find('organization_report', id);
            if (vm.report === null) {
                vm.report = JsonApiDataStore.store.sync({
                    data: [{
                        type: 'organization_report',
                        id: id,
                        attributes: {interactions: []}
                    }]
                })[0];
            }
        }

        function reportInteractions(interaction_type_id) {
            var interaction = _.find(vm.report.interactions, {interaction_type_id: interaction_type_id});
            return angular.isDefined(interaction) ? interaction.interaction_count : '-';
        }

    }
})();
