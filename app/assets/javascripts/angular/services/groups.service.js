angular.module('missionhubApp').factory('groupsService', groupsService);

function groupsService(
    $q,
    httpProxy,
    JsonApiDataStore,
    modelsService,
    moment,
    _,
) {
    var groupsService = {
        // Return a group with default field values
        getGroupTemplate: function(orgId) {
            var group = new JsonApiDataStore.Model('group');
            group.setAttribute('name', '');
            group.setAttribute('location', '');
            group.setAttribute('meets', 'weekly');
            group.setAttribute('meeting_day', 0);
            group.setAttribute('start_time', 6 * 60 * 60 * 1000);
            group.setAttribute('end_time', 7 * 60 * 60 * 1000);
            group.setRelationship(
                'organization',
                JsonApiDataStore.store.find('organization', orgId),
            );
            group.setRelationship('group_memberships', []);
            return group;
        },

        // Save a new group on the server
        createGroup: function(group, leaders) {
            // Include group_memberships so that we will have the group memberships for any newly-created leaders
            var payload = payloadFromGroup(group, leaders);
            return httpProxy
                .post(
                    modelsService.getModelMetadata('group').url.all,
                    payload,
                    {
                        params: { include: 'group_memberships' },
                        errorMessage: 'error.messages.groups.create_group',
                    },
                )
                .then(httpProxy.extractModel)
                .then(function(group) {
                    var org = group.organization;
                    if (org && org.groups) {
                        org.groups.push(group);
                    }
                    return group;
                });
        },

        // Save an existing group on the server
        updateGroup: function(group, leaders) {
            // Include group_memberships so that we will have the group memberships for any newly-created leaders
            var payload = payloadFromGroup(group, leaders);
            return httpProxy
                .put(
                    modelsService
                        .getModelMetadata('group')
                        .url.single(group.id),
                    payload,
                    {
                        params: { include: 'group_memberships' },
                        errorMessage: 'error.messages.groups.update_group',
                    },
                )
                .then(httpProxy.extractModel);
        },

        // Save a group that may or may not yet exist
        saveGroup: function(group, leaders) {
            if (group.id) {
                return groupsService.updateGroup(group, leaders);
            }
            return groupsService.createGroup(group, leaders);
        },

        // Delete a group on the server
        deleteGroup: function(group) {
            return httpProxy
                .delete(
                    modelsService
                        .getModelMetadata('group')
                        .url.single(group.id),
                    {},
                    {
                        errorMessage: 'error.messages.groups.delete_group',
                    },
                )
                .then(function() {
                    var org = group.organization;
                    if (org && org.groups) {
                        _.pull(org.groups, group);
                    }
                    return group;
                });
        },

        // Convert a time in milliseconds since midnight into a JavaScript Date object
        timeToDate: function(time) {
            return moment()
                .startOf('day')
                .milliseconds(time || 0)
                .toDate();
        },

        // Convert a JavaScript Date object into a time in milliseconds since midnight
        dateToTime: function(date) {
            return moment(date).diff(moment(date).startOf('day'));
        },

        // Load the leaders of all of an organization's groups
        loadLeaders: function(organization) {
            return loadMemberships(organization).then(function() {
                return loadMissingLeaders(organization);
            });
        },

        // Return as a list of people the members in a group
        getAllMembers: function(group) {
            return _.reduce(
                group.group_memberships,
                function(allMembers, groupMembership) {
                    // Skip all unloaded group_memberships. They seem to be loaded later
                    if (!groupMembership._placeHolder) {
                        // Map groupMembership to person
                        allMembers.push(groupMembership.person);
                    }
                    return allMembers;
                },
                [],
            );
        },

        // Return as a list of people the members in a group with a particular role
        getMembersWithRole: function(group, role) {
            return _.chain(group.group_memberships)
                .filter({ role: role })
                .map('person')
                .value();
        },

        // Find the group membership for a particular person
        findMember: function(group, person) {
            return _.find(group.group_memberships, { person: person }) || null;
        },

        // Internal methods exposed for testing purposes
        payloadFromGroup: payloadFromGroup,
        loadMemberships: loadMemberships,
        loadMissingLeaders: loadMissingLeaders,
    };

    // Return a JSON API model that represents the change in the role of a person in the group
    function modelFromRoleChange(group, person, newRole) {
        var groupMembership = _.find(group.group_memberships, {
            person: person,
        });
        groupMembership.role = newRole;
        return groupMembership.serialize({
            attributes: ['role'],
            relationships: [],
        }).data;
    }

    // Convert a group into it's JSON API payload
    function payloadFromGroup(group, leaders) {
        var previousLeaders = groupsService.getMembersWithRole(group, 'leader');
        var previousMembers = groupsService.getMembersWithRole(group, 'member');
        var previousAnyRole = groupsService.getAllMembers(group);

        // Determine which leaders were removed
        var demotedLeaders = _.difference(previousLeaders, leaders);

        // Change the demoted members' role to "member"
        var demoteModels = demotedLeaders.map(function(person) {
            return modelFromRoleChange(group, person, 'member');
        });

        // Determine which added leaders were previously members
        var promotedMembers = _.intersection(leaders, previousMembers);

        // Change the promoted members' role to "leader"
        var promoteModels = promotedMembers.map(function(person) {
            return modelFromRoleChange(group, person, 'leader');
        });

        // Determine which of the added leaders were not previously members
        var createdLeaders = _.difference(leaders, previousAnyRole);

        // Create the new members
        var createModels = createdLeaders.map(function(person) {
            var groupMembership = new JsonApiDataStore.Model(
                'group_membership',
            );
            groupMembership.setAttribute('role', 'leader');
            groupMembership.setAttribute('group_id', group.id);
            groupMembership.setAttribute('person_id', person.id);
            return groupMembership.serialize().data;
        });

        // Apply the changes
        var includedAttrs = [
            'name',
            'location',
            'meets',
            'meeting_day',
            'start_time',
            'end_time',
        ];
        var relationships = [];
        if (_.isUndefined(group.id)) {
            relationships = ['organization'];
        }
        return {
            data: group.serialize({
                attributes: includedAttrs,
                relationships: relationships,
            }).data,
            included: [].concat(demoteModels, promoteModels, createModels),
        };
    }

    // Load all of the group memberships for an organization
    function loadMemberships(organization) {
        // Don't load the groups if all of the organization's groups and memberships are loaded
        var allModelsLoaded = organization.groups.every(function(group) {
            return (
                httpProxy.isLoaded(group) &&
                group.group_memberships.every(httpProxy.isLoaded)
            );
        });
        if (allModelsLoaded) {
            return $q.resolve();
        }

        return httpProxy
            .get(
                modelsService.getModelMetadata('group').url.all,
                {
                    include: 'group_memberships',
                    'filters[organization_ids]': organization.id,
                },
                {
                    errorMessage: 'error.messages.groups.load_leaders',
                },
            )
            .then(httpProxy.extractModels);
    }

    // Load all of the unloaded leaders in an organization
    function loadMissingLeaders(organization) {
        // Find the ids of all unloaded leaders across all of the groups
        var missingLeaderIds = _.chain(organization.groups)
            .flatMap('group_memberships')
            .filter({ role: 'leader' })
            .filter(function(membership) {
                return !httpProxy.isLoaded(membership.person);
            })
            .map('person.id')
            .value();
        if (missingLeaderIds.length === 0) {
            return $q.resolve([]);
        }

        return httpProxy
            .get(
                modelsService.getModelMetadata('person').url.all,
                {
                    include: '',
                    'filters[ids]': missingLeaderIds.join(','),
                    'page[limit]': missingLeaderIds.length,
                },
                {
                    errorMessage: 'error.messages.groups.load_leaders',
                },
            )
            .then(httpProxy.extractModels);
    }

    return groupsService;
}
