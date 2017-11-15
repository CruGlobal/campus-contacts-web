import 'angular-mocks';

// Constants
var ministryViewGroupService, tFilter;

describe('ministryViewGroupService service', function () {
    beforeEach(angular.mock.module('missionhubApp'));

    beforeEach(angular.mock.module(function ($provide) {
        $provide.value('tFilter', jasmine.createSpy('tFilter'));
    }));

    beforeEach(inject(function (_ministryViewGroupService_, _tFilter_) {
        ministryViewGroupService = _ministryViewGroupService_;
        tFilter = _tFilter_;
    }));

    describe('ministryViewGroupService.formatOrdinal', function () {
        it('should convert numbers to ordinal strings', function () {
            tFilter.and.returnValue(['th', 'st', 'nd', 'rd']);
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

    describe('ministryViewGroupService.formatTime', function () {
        it('should format a time in milliseconds since midnight as a time string', function () {
            expect(ministryViewGroupService.formatTime(0)).toBe('12:00 AM');
        });

        it('should return a blank string for null times', function () {
            expect(ministryViewGroupService.formatTime(null)).toBe('');
        });
    });

    describe('ministryViewGroupService.formatMeetingTime', function () {
        it('should format weekly meeting times', function () {
            tFilter.and.returnValues('6:00 PM - 8:00 PM', 'Thursday', null);
            ministryViewGroupService.formatMeetingTime({
                meets: 'weekly',
                meeting_day: 4,
                start_time: 18 * 60 * 60 * 1000,
                end_time: 20 * 60 * 60 * 1000
            });
            expect(tFilter.calls.allArgs()).toEqual([
                ['ministries.groups.meeting_time.time_range', { start: '6:00 PM', end: '8:00 PM' }],
                ['date.day_names.4'],
                ['ministries.groups.meeting_time.weekly', { time: '6:00 PM - 8:00 PM', day: 'Thursday' }]
            ]);
        });

        it('should format monthly meeting times', function () {
            tFilter.and.returnValues('6:00 PM - 8:00 PM', ['th', 'st', 'nd', 'rd'], null);
            ministryViewGroupService.formatMeetingTime({
                meets: 'monthly',
                meeting_day: 11,
                start_time: 18 * 60 * 60 * 1000,
                end_time: 20 * 60 * 60 * 1000
            });
            expect(tFilter.calls.allArgs()).toEqual([
                ['ministries.groups.meeting_time.time_range', { start: '6:00 PM', end: '8:00 PM' }],
                ['ministries.groups.ordinal_suffixes'],
                ['ministries.groups.meeting_time.monthly', { time: '6:00 PM - 8:00 PM', day: '11th' }]
            ]);
        });

        it('should format sporadic meeting times', function () {
            tFilter.and.returnValues(' - ', null);
            ministryViewGroupService.formatMeetingTime({
                meets: 'sporadically',
                meeting_day: null,
                start_time: null,
                end_time: null
            });
            expect(tFilter.calls.allArgs()).toEqual([
                ['ministries.groups.meeting_time.time_range', { start: '', end: '' }],
                ['ministries.groups.meeting_time.sporadically']
            ]);
        });
    });
});
