import 'angular-mocks';

// Constants
var personHistoryService;

describe('personHistoryService', function() {
    beforeEach(angular.mock.module('missionhubApp'));

    beforeEach(inject(function(_personHistoryService_) {
        personHistoryService = _personHistoryService_;
    }));

    describe('buildHistoryFeed', function() {
        beforeEach(function() {
            this.note = {
                _type: 'interaction',
                interaction_type_id: 1,
                organization: {
                    id: 1,
                },
                timestamp: 4,
            };
            this.interaction = {
                _type: 'interaction',
                interaction_type_id: 2,
                organization: {
                    id: 1,
                },
                timestamp: 2,
            };
            this.answerSheet1 = {
                _type: 'answer_sheet',
                interaction_type_id: 1,
                survey: {
                    organization_id: 1,
                },
                completed_at: 3,
            };
            this.answerSheet2 = {
                _type: 'answer_sheet',
                interaction_type_id: 2,
                survey: {
                    organization_id: 1,
                },
                completed_at: 1,
            };
            this.person = {
                interactions: [this.note, this.interaction],
                answer_sheets: [this.answerSheet1, this.answerSheet2],
            };
        });

        it('should show all history', function() {
            expect(
                personHistoryService.buildHistoryFeed(this.person, 'all', 1),
            ).toEqual([
                this.answerSheet2,
                this.interaction,
                this.answerSheet1,
                this.note,
            ]);
        });

        it('should show just interactions', function() {
            expect(
                personHistoryService.buildHistoryFeed(
                    this.person,
                    'interactions',
                    1,
                ),
            ).toEqual([this.interaction]);
        });

        it('should show just notes', function() {
            expect(
                personHistoryService.buildHistoryFeed(this.person, 'notes', 1),
            ).toEqual([this.note]);
        });

        it('should show just surveys', function() {
            expect(
                personHistoryService.buildHistoryFeed(
                    this.person,
                    'surveys',
                    1,
                ),
            ).toEqual([this.answerSheet2, this.answerSheet1]);
        });

        it('should filter out history from other orgs', function() {
            this.interaction.organization.id = 2;
            this.answerSheet2.survey.organization_id = 2;
            expect(
                personHistoryService.buildHistoryFeed(this.person, 'all', 1),
            ).toEqual([this.answerSheet1, this.note]);
        });
    });
});
