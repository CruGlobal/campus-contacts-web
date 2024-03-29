angular.module('campusContactsApp').factory('ministryViewGroupService', ministryViewGroupService);

function ministryViewGroupService(groupsService, tFilter, moment, _) {
  // Convert a time in milliseconds since midnight into a human-readable string
  function formatTime(time) {
    return _.isNil(time) ? '' : moment(groupsService.timeToDate(time)).format('LT');
  }

  // Convert a number into its ordinal form (1st, 2nd, 3rd, etc.)
  function formatOrdinal(number) {
    const onesDigit = number % 10;
    const tensDigit = ((number % 100) - onesDigit) / 10;
    const suffix =
      tensDigit !== 1 && onesDigit >= 1 && onesDigit <= 3
        ? tFilter(`ministries.groups.ordinal_suffixes.${onesDigit}`)
        : tFilter('ministries.groups.ordinal_suffixes.0');
    return number + suffix;
  }

  // Return a human-readable string representing the group's meeting time
  function formatMeetingTime(group) {
    const time = tFilter('ministries.groups.meeting_time.time_range', {
      start: formatTime(group.start_time),
      end: formatTime(group.end_time),
    });

    if (group.meets === 'weekly') {
      const dayOfWeek = tFilter('date.day_names.' + group.meeting_day);
      return tFilter('ministries.groups.meeting_time.weekly', {
        time,
        day: dayOfWeek,
      });
    } else if (group.meets === 'monthly') {
      const dayOfMonth = formatOrdinal(group.meeting_day);
      return tFilter('ministries.groups.meeting_time.monthly', {
        time,
        day: dayOfMonth,
      });
    } else if (group.meets === 'sporadically') {
      return tFilter('ministries.groups.meeting_time.sporadically');
    }
  }

  return {
    formatTime,
    formatOrdinal,
    formatMeetingTime,
  };
}
