(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('groupMembersModal', {
            bindings: {
                resolve: '<',
                close: '&',
                dismiss: '&'
            },
            controller: groupMembersModalController,
            templateUrl: /* @ngInject */ function (templateUrl) {
                return templateUrl('groupMembersModal');
            }
        });

    function groupMembersModalController ($scope, $uibModal, confirmModalService, RequestDeduper, ProgressiveListLoader,
                                          groupsService, groupMembersModalService, tFilter, _) {
        var vm = this;

        vm.memberships = [];
        vm.loadedAll = false;
        vm.busy = false;
        vm.memberAdderVisible = false;
        vm.loadMemberPage = loadMemberPage;
        vm.toggleMemberAdderVisibility = toggleMemberAdderVisibility;
        vm.messageGroup = messageGroup;
        vm.emailPerson = emailPerson;
        vm.addMember = addMember;
        vm.removeMember = removeMember;

        vm.close = close;
        vm.$onInit = activate;

        var requestDeduper = new RequestDeduper();
        var listLoader = new ProgressiveListLoader({
            modelType: 'person',
            requestDeduper: requestDeduper,
            errorMessage: 'error.messages.group_members.load_member_chunk'
        });

        function activate () {
            vm.group = vm.resolve.group;

            $scope.$watchCollection('$ctrl.group.group_memberships', function () {
                vm.members = groupsService.getAllMembers(vm.group);
            });
        }

        // Load another page of members
        function loadMemberPage () {
            vm.busy = true;

            return groupMembersModalService.loadMoreGroupMembers(vm.group, listLoader)
                .then(function (res) {
                    // Convert members to memberships
                    vm.memberships = res.list.map(function (member) {
                        return groupsService.findMember(vm.group, member);
                    });
                    vm.loadedAll = res.loadedAll;
                })
                .finally(function () {
                    vm.busy = false;
                });
        }

        function toggleMemberAdderVisibility () {
            vm.memberAdderVisible = !vm.memberAdderVisible;
        }

        // Generate a selection object from an array of people
        function generateSelection (members) {
            return {
                orgId: vm.group.organization.id,
                filters: {
                    groups: [vm.group.id]
                },
                selectedPeople: members,
                unselectedPeople: [],
                totalSelectedPeople: members.length,
                allSelected: true,
                allIncluded: true
            };
        }

        function messageGroup (medium) {
            var members = groupsService.getAllMembers(vm.group);
            $uibModal.open({
                component: 'messageModal',
                resolve: {
                    medium: _.constant(medium),
                    selection: _.constant(generateSelection(members))
                },
                windowClass: 'pivot_theme',
                size: 'md'
            });
        }

        function emailPerson (person) {
            $uibModal.open({
                component: 'messageModal',
                resolve: {
                    medium: _.constant('email'),
                    selection: _.constant(generateSelection([person]))
                },
                windowClass: 'pivot_theme',
                size: 'md'
            });
        }

        function addMember (person) {
            groupMembersModalService.addMember(vm.group, person).then(function (membership) {
                vm.memberships.push(membership);
            });
        }

        function removeMember (membership) {
            confirmModalService.create(tFilter('groups.members.remove_confirm'))
                .then(function () {
                    return groupMembersModalService.removeMember(vm.group, membership);
                })
                .then(function () {
                    _.pull(vm.memberships, membership);
                });
        }

        function close () {
            vm.close();
        }
    }
})();
