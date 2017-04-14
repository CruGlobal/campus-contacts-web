(function () {
    'use strict';

    var massEditService, _;

    describe('massEditService', function () {
        beforeEach(angular.mock.module('missionhubApp'));

        beforeEach(inject(function (_massEditService_, _$rootScope_, _$q_, ___) {
            massEditService = _massEditService_;
            _ = ___;

            this.loadedModel = {};
            this.unloadedModel = { _placeHolder: true };
            this.loadedRelationship = [this.loadedModel];
            this.unloadedRelationship = [this.loadedModel, this.unloadedModel];
        }));

        describe('hashFromAddedRemoved', function () {
            it('should generate a hash of added and removed fields', function () {
                expect(massEditService.hashFromAddedRemoved([1, 4, 5], [2, 3])).toEqual({
                    1: true,
                    2: false,
                    3: false,
                    4: true,
                    5: true
                });
            });
        });

        describe('prepareChanges', function () {
            it('should filter out non-whitelisted fields', function () {
                expect(massEditService.prepareChanges({
                    foo: true,
                    bar: false
                })).toEqual({});
            });

            it('should filter out unchanged simple fields', function () {
                expect(massEditService.prepareChanges({
                    followup_status: 1,
                    cru_status: null,
                    student_status: 1,
                    gender: null
                })).toEqual({ followup_status: 1, student_status: 1 });
            });

            it('should filter out unchanged complex fields', function () {
                expect(massEditService.prepareChanges({
                    assigned_tos_added: [],
                    assigned_tos_removed: []
                })).toEqual({});
            });

            it('should prepare complex fields', function () {
                expect(massEditService.prepareChanges({
                    assigned_tos_added: [1],
                    assigned_tos_removed: [2, 3]
                })).toEqual({
                    assigned_tos: { 1: true, 2: false, 3: false }
                });
            });
        });

        describe('applyComplexChanges', function () {
            beforeEach(function () {
                this.manifest = {
                    personAttribute: 'reverse_contact_assignments',
                    modelType: 'contact_assignment',
                    getModelPredicate: function (id) {
                        return ['assigned_to.id', id];
                    },
                    getModelAttributes: function (assignedToId, person, orgId) {
                        return {
                            assigned_to: { id: assignedToId },
                            organization_id: orgId,
                            person_id: person.id
                        };
                    }
                };

                this.person = {
                    id: 1,
                    reverse_contact_assignments: [
                        { assigned_to: { id: '123' } }
                    ]
                };

                this.orgId = 2;
            });

            it('should add new related models', function () {
                massEditService.applyComplexChanges({
                    456: true
                }, this.person, this.orgId, this.manifest);
                expect(_.map(this.person.reverse_contact_assignments, 'assigned_to.id')).toEqual(['123', '456']);
            });

            it('should not add existing related models', function () {
                massEditService.applyComplexChanges({
                    123: true
                }, this.person, this.orgId, this.manifest);
                expect(_.map(this.person.reverse_contact_assignments, 'assigned_to.id')).toEqual(['123']);
            });

            it('should remove existing related models', inject(function (JsonApiDataStore) {
                spyOn(JsonApiDataStore.store, 'destroy');
                massEditService.applyComplexChanges({
                    123: false
                }, this.person, this.orgId, this.manifest);
                expect(_.map(this.person.reverse_contact_assignments, 'assigned_to.id')).toEqual([]);
                expect(JsonApiDataStore.store.destroy).toHaveBeenCalled();
            }));

            it('should not remove non-existing related models', inject(function (JsonApiDataStore) {
                spyOn(JsonApiDataStore.store, 'destroy');
                massEditService.applyComplexChanges({
                    456: false
                }, this.person, this.orgId, this.manifest);
                expect(_.map(this.person.reverse_contact_assignments, 'assigned_to.id')).toEqual(['123']);
                expect(JsonApiDataStore.store.destroy).not.toHaveBeenCalled();
            }));
        });

        describe('applyChangesLocally', function () {
            beforeEach(inject(function (JsonApiDataStore) {
                this.people = _.range(3).map(function (personId) {
                    return { id: personId };
                });

                var _this = this;
                spyOn(JsonApiDataStore.store, 'find').and.callFake(function (modelType, modelId) {
                    return {
                        person: _this.people[modelId],
                        organization: { id: modelId },
                        label: { id: modelId },
                        group: { id: modelId }
                    }[modelType] || null;
                });
            }));

            it('should copy person changes to changed people', function () {
                massEditService.applyChangesLocally({
                    selectedPeople: [0, 2]
                }, { student_status: 1 });
                expect(this.people[0].student_status).toBe(1);
                expect(this.people[1].student_status).toBeUndefined();
                expect(this.people[2].student_status).toBe(1);
            });

            it('should copy permission changes to changed people organizational permissions', function () {
                var orgId = 123;
                this.people[0].organizational_permissions = [
                    { id: 100, organization_id: orgId }
                ];
                this.people[1].organizational_permissions = [];
                this.people[2].organizational_permissions = [
                    { id: 200, organization_id: orgId + 1 },
                    { id: 201, organization_id: orgId }
                ];
                massEditService.applyChangesLocally({
                    orgId: orgId,
                    selectedPeople: [0, 2]
                }, { followup_status: 1 });
                expect(this.people[0].organizational_permissions[0].followup_status).toBe(1);
                expect(this.people[1].organizational_permissions[0]).toBeUndefined();
                expect(this.people[2].organizational_permissions[1].followup_status).toBe(1);
            });

            it('should add and remove assignments', inject(function (JsonApiDataStore) {
                this.people[0].reverse_contact_assignments = [
                    { assigned_to: { id: '1' } }
                ];
                spyOn(JsonApiDataStore.store, 'destroy');
                massEditService.applyChangesLocally({
                    selectedPeople: [0]
                }, { assigned_tos: { 1: false, 2: true } });
                expect(_.map(this.people[0].reverse_contact_assignments, 'assigned_to.id')).toEqual([2]);
                expect(JsonApiDataStore.store.destroy).toHaveBeenCalled();
            }));

            it('should add and remove labels', inject(function (JsonApiDataStore) {
                this.people[0].organizational_labels = [
                    { label: { id: '1' } }
                ];
                spyOn(JsonApiDataStore.store, 'destroy');
                massEditService.applyChangesLocally({
                    selectedPeople: [0]
                }, { labels: { 1: false, 2: true } });
                expect(_.map(this.people[0].organizational_labels, 'label.id')).toEqual(['2']);
                expect(JsonApiDataStore.store.destroy).toHaveBeenCalled();
            }));

            it('should add and remove groups', inject(function (JsonApiDataStore) {
                this.people[0].group_memberships = [
                    { group: { id: '1' } }
                ];
                spyOn(JsonApiDataStore.store, 'destroy');
                massEditService.applyChangesLocally({
                    selectedPeople: [0]
                }, { groups: { 1: false, 2: true } });
                expect(_.map(this.people[0].group_memberships, 'group.id')).toEqual(['2']);
                expect(JsonApiDataStore.store.destroy).toHaveBeenCalled();
            }));
        });

        describe('personHasUnloadedRelationships', function () {
            it('should should return true for unloaded relationships', function () {
                expect(massEditService.personHasUnloadedRelationships({
                    relationship1: this.loadedRelationship,
                    relationship2: this.unloadedRelationship
                }, ['relationship1', 'relationship2'])).toBe(true);
            });

            it('should should return false for loaded relationships', function () {
                expect(massEditService.personHasUnloadedRelationships({
                    relationship1: this.loadedRelationship,
                    relationship2: this.loadedRelationship
                }, ['relationship1', 'relationship2'])).toBe(false);
            });
        });

        describe('relationshipHasUnloadedModels', function () {
            it('should return true for unloaded models', function () {
                expect(massEditService.relationshipHasUnloadedModels(this.unloadedRelationship)).toBe(true);
            });

            it('should return false for loaded models', function () {
                expect(massEditService.relationshipHasUnloadedModels(this.loadedRelationship)).toBe(false);
            });
        });

        describe('optionsForStatsType', function () {
            beforeEach(function () {
                this.stats = {
                    assigned_tos: [
                        { person_id: 1, name: 'Adam', count: 1 },
                        { person_id: 2, name: 'Bill', count: 1 }
                    ]
                };
                this.selection = {};
                spyOn(massEditService, 'optionStateFromModel').and.returnValue(true);
            });

            it('should generate options from the stats', function () {
                expect(massEditService.optionsForStatsType(this.stats, 'assigned_tos', this.select)).toEqual([
                    { id: 1, name: 'Adam', state: true },
                    { id: 2, name: 'Bill', state: true }
                ]);
            });

            it('should set the state to unselected for empty stats', function () {
                this.stats.assigned_tos[0].count = 0;
                expect(massEditService.optionsForStatsType(this.stats, 'assigned_tos', this.select)).toEqual([
                    { id: 1, name: 'Adam', state: false },
                    { id: 2, name: 'Bill', state: true }
                ]);
            });
        });

        describe('optionsFromStats', function () {
            it('should generate options for all types from the stats', function () {
                this.stats = {};
                this.selection = {};
                this.assignedTos = [];
                this.labels = [];
                this.groups = [];
                spyOn(massEditService, 'optionsForStatsType').and.returnValues(
                    this.assignedTos,
                    this.labels,
                    this.groups
                );
                expect(massEditService.optionsFromStats(this.stats, this.selection)).toEqual({
                    assigned_tos: this.assignedTos,
                    labels: this.labels,
                    groups: this.groups
                });
            });
        });

        describe('optionStateFromModel', function () {
            beforeEach(inject(function (JsonApiDataStore) {
                this.people = _.range(3).map(function (personId) {
                    return { id: personId };
                });

                var people = this.people;
                spyOn(JsonApiDataStore.store, 'find').and.callFake(function (modelType, modelId) {
                    return people[modelId];
                });

                this.model = {};

                this.selection = {
                    allSelected: false,
                    allIncluded: true,
                    orgId: 1,
                    selectedPeople: [0, 1]
                };
            }));

            it('should return indeterminate when some unincluded people are selected', function () {
                this.selection.allSelected = true;
                this.selection.allIncluded = false;
                expect(massEditService.optionStateFromModel(this.model, this.selection, _.noop)).toBe(null);
            });

            it('should return unselected when no people are selected', function () {
                this.selection.selectedPeople = [];
                expect(massEditService.optionStateFromModel(this.model, this.selection, _.noop)).toBe(false);
            });

            it('should call personHasModel once per selected person', function () {
                var personHasModel = jasmine.createSpy();
                massEditService.optionStateFromModel(this.model, this.selection, personHasModel);
                expect(personHasModel.calls.allArgs()).toEqual([
                    [this.people[0], this.selection.orgId, this.model],
                    [this.people[1], this.selection.orgId, this.model]
                ]);
            });

            it('should return selected when all selected people have the model', function () {
                var personHasModel = jasmine.createSpy().and.returnValues(true, true);
                expect(massEditService.optionStateFromModel(this.model, this.selection, personHasModel)).toBe(true);
            });

            it('should return unselected when no selected people have the model', function () {
                var personHasModel = jasmine.createSpy().and.returnValues(false, false);
                expect(massEditService.optionStateFromModel(this.model, this.selection, personHasModel)).toBe(false);
            });

            it('should return indeterminate when some selected people have the model', function () {
                var personHasModel = jasmine.createSpy().and.returnValues(true, false);
                expect(massEditService.optionStateFromModel(this.model, this.selection, personHasModel)).toBe(null);
            });
        });

        describe('personHasAssignment', function () {
            beforeEach(function () {
                this.teamMember = { id: 1 };
                this.wrongTeamMember = { id: 2 };
                this.orgId = 123;
                this.org = { id: this.orgId };
                this.wrongOrg = { id: 234 };
                this.matchingAssignment = { assigned_to: this.teamMember, organization: this.org };
                this.wrongPersonAssignment = { assigned_to: this.wrongTeamMember, organization: this.org };
                this.wrongOrgAssignment = { assigned_to: this.teamMember, organization: this.wrongOrg };
            });

            it('should return true if the person is assigned to the team member', function () {
                expect(massEditService.personHasAssignment({
                    reverse_contact_assignments: [this.matchingAssignment]
                }, this.orgId, this.teamMember)).toBe(true);
            });

            it('should return false if the person is not assigned to the team member', function () {
                expect(massEditService.personHasAssignment({
                    reverse_contact_assignments: [this.wrongPersonAssignment, this.wrongOrgAssignment]
                }, this.orgId, this.teamMember)).toBe(false);
            });
        });

        describe('personHasLabel', function () {
            beforeEach(function () {
                this.personId = 1;
                this.label = { id: 123 };
                this.wrongLabel = { id: 234 };
                this.orgId = 456;
                this.wrongOrgId = 567;
                this.matchingLabel = { organization_id: this.orgId, label: this.label };
                this.wrongIdLabel = { organization_id: this.orgId, label: this.wrongLabel };
                this.wrongOrgLabel = { organization_id: this.wrongOrgId, label: this.label };
            });

            it('should return true if the person has the label', function () {
                expect(massEditService.personHasLabel({
                    id: this.personId,
                    organizational_labels: [this.matchingLabel]
                }, this.orgId, this.label)).toBe(true);
            });

            it('should return false if the person does not have the label', function () {
                expect(massEditService.personHasLabel({
                    id: this.personId,
                    organizational_labels: [this.wrongIdLabel, this.wrongOrgLabel]
                }, this.orgId, this.label)).toBe(false);
            });
        });

        describe('personHasGroup', function () {
            beforeEach(function () {
                this.personId = 1;
                this.group = { id: 123 };
                this.wrongGroup = { id: 234 };
                this.matchingGroup = { group: this.group };
                this.wrongIdGroup = { group: this.wrongGroup };
            });

            it('should return true if the person has the group', function () {
                expect(massEditService.personHasGroup({
                    id: this.personId,
                    group_memberships: [this.matchingGroup]
                }, this.orgId, this.group)).toBe(true);
            });

            it('should return false if the person does not have the group', function () {
                expect(massEditService.personHasGroup({
                    id: this.personId,
                    group_memberships: [this.wrongIdGroup]
                }, this.orgId, this.group)).toBe(false);
            });
        });

        describe('selectionFromOptions', function () {
            it('should return a selection object', function () {
                expect(massEditService.selectionFromOptions([
                    { id: 1, state: true },
                    { id: 2, state: false },
                    { id: 3, state: true }
                ])).toEqual({
                    1: true,
                    2: false,
                    3: true
                });
            });
        });
    });
})();
