import template from './transferModal.html';
import './transferModal.scss';

angular.module('missionhubApp').component('transferModal', {
    controller: transferModalController,
    template: template,
    bindings: {
        resolve: '<',
        close: '&',
        dismiss: '&',
    },
});

function transferModalController(
    $scope,
    JsonApiDataStore,
    transferService,
    organizationService,
    RequestDeduper,
) {
    var vm = this;

    vm.search = '';
    vm.searching = false;
    vm.searchOptions = [];
    vm.selectedOrg = null;
    vm.selectOrg = selectOrg;
    vm.options = {
        copyContact: false,
        copyAnswers: false,
        copyInteractions: false,
    };

    vm.save = save;
    vm.cancel = cancel;

    vm.$onInit = activate;

    function activate() {
        vm.selection = vm.resolve.selection;
        vm.sourceOrg = JsonApiDataStore.store.find(
            'organization',
            vm.selection.orgId,
        );

        var requestDeduper = new RequestDeduper();

        // Refresh the org list whenever the search term changes
        $scope.$watch('$ctrl.search', function(search) {
            // Unselect the org because it may not be shown anymore
            vm.selectedOrg = null;

            if (search === '') {
                // Ignore empty searches
                vm.searchOptions = [];
                return;
            }

            vm.searching = true;
            organizationService
                .searchOrgs(vm.sourceOrg, search, requestDeduper)
                .then(function(orgs) {
                    // Filter out people that are already selected
                    vm.searchOptions = orgs;
                })
                .finally(function() {
                    vm.searching = false;
                });
        });
    }

    function selectOrg(org) {
        vm.selectedOrg = org;
    }

    function save() {
        vm.saving = true;
        transferService
            .transfer(vm.selection, vm.selectedOrg, vm.options)
            .then(function() {
                vm.close({ $value: vm.options.copyContact });
            })
            .catch(function() {
                vm.saving = false;
            });
    }

    function cancel() {
        vm.dismiss();
    }
}
