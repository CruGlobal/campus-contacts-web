import 'angular-mocks';

// Constants
var ministryViewGroupService, tFilter;

describe('ministryViewGroupService service', function() {
    beforeEach(inject(function(_ministryViewGroupService_) {
        ministryViewGroupService = _ministryViewGroupService_;
    }));

    describe('ministryViewGroupService.formatOrdinal', function() {
        it('should convert numbers to ordinal strings', function() {
            expect(ministryViewGroupService.formatOrdinal(0)).toBe('0th');
            expect(ministryViewGroupService.formatOrdinal(1)).toBe('1st');
            expect(ministryViewGroupService.formatOrdinal(2)).toBe('2nd');
            expect(ministryViewGroupService.formatOrdinal(3)).toBe('3rd');
            expect(ministryViewGroupService.formatOrdinal(4)).toBe('4th');
            expect(ministryViewGroupService.formatOrdinal(10)).toBe('10th');
            expect(ministryViewGroupService.formatOrdinal(11)).toBe('11th');
            expect(ministryViewGroupService.formatOrdinal(12)).toBe('12th');
            expect(ministryViewGroupService.formatOrdinal(13)).toBe('13th');
            expect(ministryViewGroupService.formatOrdinal(14)).toBe('14th');
            expect(ministryViewGroupService.formatOrdinal(20)).toBe('20th');
            expect(ministryViewGroupService.formatOrdinal(21)).toBe('21st');
            expect(ministryViewGroupService.formatOrdinal(22)).toBe('22nd');
            expect(ministryViewGroupService.formatOrdinal(23)).toBe('23rd');
            expect(ministryViewGroupService.formatOrdinal(24)).toBe('24th');
        });
    });

    describe('ministryViewGroupService.formatTime', function() {
        it('should format a time in milliseconds since midnight as a time string', function() {
            expect(ministryViewGroupService.formatTime(0)).toBe('12:00 AM');
        });

        it('should return a blank string for null times', function() {
            expect(ministryViewGroupService.formatTime(null)).toBe('');
        });
    });

    describe('ministryViewGroupService.formatMeetingTime', function() {
        it('should format weekly meeting times', function() {
            expect(
                ministryViewGroupService.formatMeetingTime({
                    meets: 'weekly',
                    meeting_day: 4,
                    start_time: 18 * 60 * 60 * 1000,
                    end_time: 20 * 60 * 60 * 1000,
                }),
            ).toEqual('Weekly on Thursdays 6:00 PM - 8:00 PM');
        });

        it('should format monthly meeting times', function() {
            expect(
                ministryViewGroupService.formatMeetingTime({
                    meets: 'monthly',
                    meeting_day: 11,
                    start_time: 18 * 60 * 60 * 1000,
                    end_time: 20 * 60 * 60 * 1000,
                }),
            ).toEqual('Monthly on the 11th from 6:00 PM - 8:00 PM');
        });

        it('should format sporadic meeting times', function() {
            expect(
                ministryViewGroupService.formatMeetingTime({
                    meets: 'sporadically',
                    meeting_day: null,
                    start_time: null,
                    end_time: null,
                }),
            ).toEqual('Sporadically');
        });
    });
});
