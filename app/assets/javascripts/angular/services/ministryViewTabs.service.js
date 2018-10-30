const ministryViewTabs = [
    'suborgs',
    'team',
    'groups',
    'people',
    'surveys',
    'surveyResponses',
    'labels',
];
angular
    .module('missionhubApp')
    .constant('ministryViewTabs', ministryViewTabs)
    .constant('ministryViewDefaultTab', ministryViewTabs[0]);
