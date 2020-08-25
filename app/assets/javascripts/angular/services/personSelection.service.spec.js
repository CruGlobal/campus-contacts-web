var personSelectionService;

describe('personSelectionService', function () {
    beforeEach(inject(function (_personSelectionService_) {
        personSelectionService = _personSelectionService_;
    }));

    describe('containsUnincludedPeople', function () {
        it('should return true when all people are selected and all people are not included', function () {
            expect(
                personSelectionService.containsUnincludedPeople({
                    allSelected: true,
                    allIncluded: false,
                }),
            ).toBe(true);
        });

        it('should return false otherwise', function () {
            expect(
                personSelectionService.containsUnincludedPeople({
                    allSelected: false,
                    allIncluded: true,
                }),
            ).toBe(false);
            expect(
                personSelectionService.containsUnincludedPeople({
                    allSelected: true,
                    allIncluded: true,
                }),
            ).toBe(false);
        });
    });

    describe('convertToFilters', function () {
        beforeEach(function () {
            this.orgId = 123;
        });

        it('should filter by id when all people are not selected', function () {
            expect(
                personSelectionService.convertToFilters({
                    orgId: this.orgId,
                    allSelected: false,
                    selectedPeople: [1, 2, 3],
                }),
            ).toEqual({
                ids: '1,2,3',
            });
        });

        it('should correctly transform filter attribute names and values', function () {
            expect(
                personSelectionService.convertToFilters({
                    orgId: this.orgId,
                    surveyId: '10',
                    allSelected: true,
                    allIncluded: false,
                    unselectedPeople: [31, 32, 33],
                    filters: {
                        assignedTos: [1, 2, 3],
                        labels: [11, 12, 13],
                        groups: [21, 22, 23],
                        searchString: 'John',
                        statuses: ['attempted_contact'],
                        genders: ['Female'],
                        includeArchived: true,
                        questions: { 5: ['One'] },
                        answerMatchingOptions: { 5: 'contains' },
                    },
                }),
            ).toEqual({
                organization_ids: this.orgId,
                assigned_tos: '1,2,3',
                label_ids: '11,12,13',
                group_ids: '21,22,23',
                exclude_ids: '31,32,33',
                name: 'John',
                statuses: ['attempted_contact'],
                genders: ['Female'],
                include_archived: true,
                answer_sheets: {
                    survey_ids: '10',
                    answers: { 5: ['One'] },
                    answers_options: { 5: 'contains' },
                },
            });
        });

        it('should default missing filter attributes', function () {
            expect(
                personSelectionService.convertToFilters({
                    orgId: this.orgId,
                    allSelected: true,
                    allIncluded: false,
                    filters: {
                        searchString: 'John',
                    },
                }),
            ).toEqual({
                organization_ids: this.orgId,
                name: 'John',
            });
        });

        it('should ignore empty filter attributes', function () {
            expect(
                personSelectionService.convertToFilters({
                    orgId: this.orgId,
                    allSelected: true,
                    allIncluded: false,
                    filters: {
                        assignedTos: [],
                        labels: [],
                        groups: [],
                        searchString: '',
                    },
                    exclude_ids: [],
                }),
            ).toEqual({
                organization_ids: this.orgId,
            });
        });
    });
});
