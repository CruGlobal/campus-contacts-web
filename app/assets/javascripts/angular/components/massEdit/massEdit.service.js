angular.module('missionhubApp').factory('massEditService', massEditService);

function massEditService(
    $q,
    httpProxy,
    JsonApiDataStore,
    modelsService,
    personSelectionService,
    _,
) {
    // Return a boolean indicating whether a particular person is assigned to the team member
    function personHasAssignment(person, orgId, teamMember) {
        return Boolean(
            _.find(person.reverse_contact_assignments, function(assignment) {
                return (
                    assignment.organization.id === orgId &&
                    assignment.assigned_to.id === teamMember.id
                );
            }),
        );
    }

    // Return a boolean indicating whether a particular person has the label
    function personHasLabel(person, orgId, label) {
        return Boolean(
            _.find(person.organizational_labels, function(organizationalLabel) {
                return (
                    organizationalLabel.organization_id === orgId &&
                    organizationalLabel.label.id === label.id
                );
            }),
        );
    }

    // Return a boolean indicating whether a particular person has the group
    function personHasGroup(person, orgId, group) {
        return Boolean(
            _.find(person.group_memberships, ['group.id', group.id]),
        );
    }

    // Define the mass editable attributes that are simple values (i.e. a number or a string)
    var simpleChangeManifests = {
        student_status: { type: 'person' },
        gender: { type: 'person' },
        followup_status: { type: 'permission' },
        cru_status: { type: 'permission' },
        archived: { type: null },
        delete: { type: null },
    };

    // List of mass editable attributes that are simple values
    var simpleChangeFields = _.keys(simpleChangeManifests);

    // List of mass editable attributes that are on the person model
    var personChangeFields = _.keys(
        _.pickBy(simpleChangeManifests, { type: 'person' }),
    );

    // List of mass editable attributes that are on the organizational permission model
    var permissionChangeFields = _.keys(
        _.pickBy(simpleChangeManifests, { type: 'permission' }),
    );

    // Define the mass editable attributes that are complex values (i.e. an { id: Boolean } hash of added/removed
    // models)
    // The manifest is in the format expected by applyComplexChanges
    var complexChangeManifests = {
        assigned_tos: {
            personAttribute: 'reverse_contact_assignments',
            modelType: 'contact_assignment',
            getModelPredicate: function(assignedToId) {
                return ['assigned_to.id', assignedToId];
            },
            getModelAttributes: function(assignedToId, person, organizationId) {
                return {
                    assigned_to: JsonApiDataStore.store.find(
                        'person',
                        assignedToId,
                    ),
                    organization: JsonApiDataStore.store.find(
                        'organization',
                        organizationId,
                    ),
                    person_id: person.id,
                };
            },
        },
        labels: {
            personAttribute: 'organizational_labels',
            modelType: 'organizational_label',
            getModelPredicate: function(labelId) {
                return ['label.id', labelId];
            },
            getModelAttributes: function(labelId, person, organizationId) {
                return {
                    label: JsonApiDataStore.store.find('label', labelId),
                    organization_id: organizationId,
                    person_id: person.id,
                };
            },
        },
        groups: {
            personAttribute: 'group_memberships',
            modelType: 'group_membership',
            getModelPredicate: function(groupId) {
                return ['group.id', groupId];
            },
            getModelAttributes: function(groupId, person, organizationId) {
                // eslint-disable-line no-unused-vars
                return {
                    group: JsonApiDataStore.store.find('group', groupId),
                    person: person,
                    role: 'member',
                };
            },
        },
    };

    // List of mass editable attributes that are complex values
    var complexChangeFields = _.keys(complexChangeManifests);

    var massEditService = {
        // Convert a list of added and removed ids into a hash with keys matching the ids and a value of true for
        // added and false for removed
        hashFromAddedRemoved: function(addedIds, removedIds) {
            return _.extend(
                _.zipObject(addedIds, _.fill(Array(addedIds.length), true)),
                _.zipObject(
                    removedIds,
                    _.fill(Array(removedIds.length), false),
                ),
            );
        },

        // Convert a changes object from the massEdit component into the form expected by the bulk people changes
        // endpoint
        prepareChanges: function(changes) {
            var filteredChanges = {};
            simpleChangeFields.forEach(function(field) {
                // A value of null or undefined means no change, so ignore those changes
                if (!_.isNil(changes[field])) {
                    filteredChanges[field] = changes[field];
                }
            });
            complexChangeFields.forEach(function(field) {
                var addedIds = changes[field + '_added'] || [];
                var removedIds = changes[field + '_removed'] || [];

                // Empty added ids and removed ids means no change, so ignore those changes
                if (addedIds.length + removedIds.length > 0) {
                    // Turn a list of added and removed fields into an object
                    filteredChanges[
                        field
                    ] = massEditService.hashFromAddedRemoved(
                        addedIds,
                        removedIds,
                    );
                }
            });
            return filteredChanges;
        },

        // Apply the changes on the server
        applyChanges: function(selection, changes) {
            var filteredChanges = massEditService.prepareChanges(changes);
            massEditService.applyChangesLocally(selection, filteredChanges);

            var normalizedFilters = personSelectionService.convertToFilters(
                selection,
            );

            var payload = {
                data: {
                    type: 'bulk_people_change',
                    attributes: _.extend(
                        {
                            organization_id: selection.orgId,

                            // Prefer using person_ids over selection.ids because the former does validation that the
                            // latter does not. If person_ids is truthy, it will override the selection.
                            person_ids: normalizedFilters.ids,
                        },
                        filteredChanges,
                    ),
                },
                filters: normalizedFilters,
            };
            return httpProxy
                .post('/bulk_people_changes', payload, {
                    errorMessage: 'error.messages.mass_edit.apply_mass_edit',
                })
                .then(httpProxy.extractModels);
        },

        // Apply changes that involve modifying a one-to-many relationship (like assignments, group memberships,
        // or label applications) to a person
        /*
         * manifest schema:
         * {
         *     // The attribute on the person model with the related models can be found
         *     personAttribute,
         *
         *     // The type of the related models
         *     modelType,
         *
         *     // Returns the predicate used by _.find to locate an existing related model
         *     getModelPredicate(id),
         *
         *     // Returns the attributes to be applied to a new related model
         *     getModelAttributes(id, person)
         * }
         */
        applyComplexChanges: function(
            changes,
            person,
            organizationId,
            manifest,
        ) {
            _.forEach(changes, function(change, id) {
                var existingModel = _.find(
                    person[manifest.personAttribute],
                    manifest.getModelPredicate(id),
                );

                if (change === true && !existingModel) {
                    // Add a model
                    var addedAssignment = new JsonApiDataStore.Model(
                        manifest.modelType,
                    );
                    _.extend(
                        addedAssignment,
                        manifest.getModelAttributes(id, person, organizationId),
                    );
                    person[manifest.personAttribute].push(addedAssignment);
                } else if (change === false && existingModel) {
                    // Remove a model
                    JsonApiDataStore.store.destroy(existingModel);
                    _.pull(person[manifest.personAttribute], existingModel);
                }
            });
        },

        // Apply the changes locally
        applyChangesLocally: function(selection, changes) {
            var orgId = selection.orgId;

            selection.selectedPeople.forEach(function(personId) {
                var person = JsonApiDataStore.store.find('person', personId);
                var orgPermission = _.find(person.organizational_permissions, {
                    organization_id: orgId,
                });

                // Changes to person fields can be simply copied to the person model
                _.extend(person, _.pick(changes, personChangeFields));

                // Changes to permission fields can be simply copied to the organizational permission model
                if (orgPermission) {
                    _.extend(
                        orgPermission,
                        _.pick(changes, permissionChangeFields),
                    );
                }

                _.each(complexChangeManifests, function(
                    changeManifest,
                    changeField,
                ) {
                    massEditService.applyComplexChanges(
                        changes[changeField],
                        person,
                        orgId,
                        changeManifest,
                    );
                });
            });
        },

        statDefinitions: [
            {
                type: 'assigned_tos',
                idField: 'person_id',
                personHasModel: personHasAssignment,
            },
            {
                type: 'labels',
                idField: 'label_id',
                personHasModel: personHasLabel,
            },
            {
                type: 'groups',
                idField: 'group_id',
                personHasModel: personHasGroup,
            },
        ],

        // Return a boolean indicating whether a person has any unloaded relationships
        personHasUnloadedRelationships: function(person, relationshipNames) {
            // Consider the person to be missing if any of its relationships are missing
            return relationshipNames.some(function(relationshipName) {
                return massEditService.relationshipHasUnloadedModels(
                    person[relationshipName],
                );
            });
        },

        // Return a boolean indicating whether a relationship has any unloaded models
        relationshipHasUnloadedModels: function(relationship) {
            return relationship.some(_.negate(httpProxy.isLoaded));
        },

        // Load the necessary relationships for a selection
        loadPeopleRelationships: function(selection) {
            // Optimize by only loading relationships when optionStateFromModel will actually use those
            // relationships when determining option selection states
            if (personSelectionService.containsUnincludedPeople(selection)) {
                return $q.resolve();
            }

            // The "reverse_contact_assignments" relationship is needed also, but it is already being loaded by
            // organizationOverviewPeopleService.loadMoreOrgPeople
            var relationships = ['organizational_labels', 'group_memberships'];

            // Only load people for whom at least one of their relationships contains a placeholder model
            var peopleMissingRelationships = selection.selectedPeople.filter(
                function(personId) {
                    var person = JsonApiDataStore.store.find(
                        'person',
                        personId,
                    );
                    return massEditService.personHasUnloadedRelationships(
                        person,
                        relationships,
                    );
                },
            );

            // Only make a network request if there are people that need their relationships loaded
            return peopleMissingRelationships === 0
                ? $q.resolve()
                : httpProxy.get(
                      modelsService.getModelMetadata('person').url.all,
                      {
                          include: relationships.join(','),
                          'filters[organization_ids]': selection.orgId,
                          'filters[ids]': peopleMissingRelationships.join(','),
                      },
                      {
                          errorMessage:
                              'error.messages.mass_edit.load_relationships',
                      },
                  );
        },

        // Load the filter stats for an organization
        loadFilterStats: function(orgId) {
            return httpProxy
                .get(
                    modelsService
                        .getModelMetadata('filter_stats')
                        .url.single('people'),
                    {
                        organization_id: orgId,
                        include_zeros: true,
                    },
                    {
                        errorMessage: 'error.messages.mass_edit.load_options',
                    },
                )
                .then(httpProxy.extractModel);
        },

        // Return an array of options generated from a particular type of stats
        optionsForStatsType: function(stats, statType, selection) {
            var statDefinition = _.find(massEditService.statDefinitions, {
                type: statType,
            });
            return stats[statDefinition.type].map(function(stat) {
                var id = stat[statDefinition.idField];
                var state;
                if (stat.count === 0) {
                    // This stat is empty, so automatically treat this option as unselected
                    state = false;
                } else {
                    state = massEditService.optionStateFromModel(
                        { id: id, count: stat.count },
                        selection,
                        statDefinition.personHasModel,
                    );
                }
                return {
                    id: id,
                    name: stat.name,
                    state: state,
                };
            });
        },

        // Return the options generated from a stats model
        optionsFromStats: function(stats, selection) {
            var statTypes = _.map(massEditService.statDefinitions, 'type');
            return _.fromPairs(
                statTypes.map(function(statType) {
                    // Key is the type, value is the options
                    return [
                        statType,
                        massEditService.optionsForStatsType(
                            stats,
                            statType,
                            selection,
                        ),
                    ];
                }),
            );
        },

        // Return a promise that resolves to the available multiselect options
        loadOptions: function(selection) {
            return $q
                .all([
                    // Load the filter stats because they include the id and name of all possible assignments, labels,
                    // and groups and can therefore be used as the basis for calculating the options
                    massEditService.loadFilterStats(selection.orgId),

                    // In parallel, load the relationships needed to determine which options are selected
                    massEditService.loadPeopleRelationships(selection),
                ])
                .then(function(results) {
                    var stats = results[0];
                    return massEditService.optionsFromStats(stats, selection);
                });
        },

        // Determine the right state for a generic model option
        // If all people "have" the model, return true, if no people "have" the model, return false, and if some
        // people "have" the model, return indeterminate.
        // "model" is the model option in question (such as a label, group, or contact assignment, for example).
        // "personHasModel" is expected to implement the algorithm for determining whether a person "has" a model.
        // It is called with the model and the person in question.
        optionStateFromModel: function(model, selection, personHasModel) {
            if (personSelectionService.containsUnincludedPeople(selection)) {
                // When unincluded contacts are selected, all options are automatically treated as indeterminate
                return null;
            }
            if (selection.selectedPeople.length === 0) {
                // When no contacts are selected, all options are automatically treated as unselected
                return false;
            }

            // Convert the array of person ids into an array of people
            var selectedPeople = selection.selectedPeople.map(function(
                personId,
            ) {
                return JsonApiDataStore.store.find('person', personId);
            });

            // Gather a list of the people with the model
            var matchingPeople = selectedPeople.filter(function(person) {
                return personHasModel(person, selection.orgId, model);
            });

            // Determine whether all of the selected people have the model
            var allSelected = matchingPeople.length === selectedPeople.length;

            // Determine whether none of the selected people have the models
            var noneSelected = matchingPeople.length === 0;

            if (noneSelected) {
                // Unselected
                return false;
            }
            if (allSelected) {
                // Selected
                return true;
            }

            // Indeterminate
            return null;
        },

        personHasAssignment: personHasAssignment,
        personHasLabel: personHasLabel,
        personHasGroup: personHasGroup,

        // Return an option selection object from an array of options
        selectionFromOptions: function(options) {
            return _.chain(options)
                .map(function(option) {
                    return [option.id, option.state];
                })
                .fromPairs()
                .value();
        },
    };

    return massEditService;
}
