ministryViewGroupService.$inject = ['groupsService', 'tFilter', 'moment', '_'];
angular
  .module('missionhubApp')
  .factory('ministryViewGroupService', ministryViewGroupService);

function ministryViewGroupService(groupsService, tFilter, moment, _) {
  // Convert a time in milliseconds since midnight into a human-readable string
  function formatTime(time) {
    return _.isNil(time)
      ? ''
      : moment(groupsService.timeToDate(time)).format('LT');
  }

  // Convert a number into its ordinal form (1st, 2nd, 3rd, etc.)
  function formatOrdinal(number) {
    var suffixes = tFilter('ministries.groups.ordinal_suffixes');
    var onesDigit = number % 10;
    var tensDigit = ((number % 100) - onesDigit) / 10;
    var suffix =
      tensDigit !== 1 && onesDigit >= 1 && onesDigit <= 3
        ? suffixes[onesDigit]
        : suffixes[0];
    return number + suffix;
  }

  // Return a human-readable string representing the group's meeting time
  function formatMeetingTime(group) {
    var time = tFilter('ministries.groups.meeting_time.time_range', {
      start: formatTime(group.start_time),
      end: formatTime(group.end_time),
    });

    if (group.meets === 'weekly') {
      var dayOfWeek = tFilter('date.day_names.' + group.meeting_day);
      return tFilter('ministries.groups.meeting_time.weekly', {
        time: time,
        day: dayOfWeek,
      });
    } else if (group.meets === 'monthly') {
      var dayOfMonth = formatOrdinal(group.meeting_day);
      return tFilter('ministries.groups.meeting_time.monthly', {
        time: time,
        day: dayOfMonth,
      });
    } else if (group.meets === 'sporadically') {
      return tFilter('ministries.groups.meeting_time.sporadically');
    }
  }

  return {
    formatTime: formatTime,
    formatOrdinal: formatOrdinal,
    formatMeetingTime: formatMeetingTime,
  };
}
