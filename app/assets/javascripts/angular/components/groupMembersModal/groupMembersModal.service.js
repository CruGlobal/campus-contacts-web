(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('groupMembersModalService', groupMembersModalService);

    function groupMembersModalService (httpProxy, JsonApiDataStore, modelsService, _) {
        return {
            // Load another chunk of group members
            loadMoreGroupMembers: function (group, listLoader) {
                // All of the group's group_memberships should have already been loaded by groupsService.loadLeaders,
                // but load the group_memberships anyway, just in case that request has not completed yet
                return listLoader.loadMore({
                    include: 'email_addresses,phone_numbers,group_memberships',
                    'filters[organization_ids]': group.organization.id,
                    'filters[group_ids]': group.id
                });
            },

            // Add a member to the group
            addMember: function (group, person) {
                var membership = new JsonApiDataStore.Model('group_membership');
                membership.setAttribute('role', 'member');
                membership.setAttribute('group_id', group.id);
                membership.setAttribute('person_id', person.id);

                var payload = membership.serialize();
                return httpProxy.post(modelsService.getModelMetadata('group_membership').url.all, payload, {
                    errorMessage: 'error.messages.group_members.add_member'
                })
                    .then(httpProxy.extractModel)
                    .then(function (membership) {
                        group.group_memberships.push(membership);
                        return membership;
                    });
            },

            // Remove a member from a group
            removeMember: function (group, membership) {
                var url = modelsService.getModelMetadata('group_membership').url.single(membership.id);
                return httpProxy.delete(url, {}, {
                    errorMessage: 'error.messages.group_members.remove_member'
                }).then(function () {
                    _.pull(group.group_memberships, membership);
                });
            }
        };
    }
})();
