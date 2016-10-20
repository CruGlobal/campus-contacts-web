(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('pages', {
            bindings: {
                loadPage: '<',
                onNewData: '&'
            },
            controller: pagesController,
            templateUrl: '/assets/angular/components/pages/pages.html'
        });

    function pagesController ($scope, JsonApiDataStore) {
        var vm = this;
        vm.page = null;
        vm.pageCount = 1;
        vm.pageSize = 25;
        vm.pageSizeOptions = [10, 25, 50, 100, 250, 500, 1000];
        vm.$onInit = activate;
        vm.isFirstPage = isFirstPage;
        vm.isLastPage = isLastPage;
        vm.gotoPage = gotoPage;

        function activate () {
            vm.onNewData(null);
            vm.gotoPage(0);

            // Update the page whenever the page size changes to ensure
            // that as much of the same data as possible is still shown
            $scope.$watch('$ctrl.pageSize', function (newPageSize, oldPageSize) {
                if (newPageSize !== oldPageSize) {
                    vm.gotoPage(Math.floor(vm.page * oldPageSize / newPageSize));
                }
            });
        }

        // Return true if the first page is active
        function isFirstPage () {
            return vm.page === 0;
        }

        // Return true if the last page is active
        function isLastPage () {
            return vm.page === vm.pageCount - 1;
        }

        // Navigate to the specified page number
        function gotoPage (page) {
            vm.page = page;
            vm.loadPage({
                limit: vm.pageSize,
                offset: vm.page * vm.pageSize
            }).then(function (response) {
                vm.pageCount = Math.ceil(response.meta.total / vm.pageSize);
                vm.onNewData({
                    newData: response.data.map(function (person) {
                        return JsonApiDataStore.store.find(person.type, person.id);
                    })
                });
            });
        }
    }
})();
