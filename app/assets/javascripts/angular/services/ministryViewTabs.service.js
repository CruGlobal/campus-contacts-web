var ministryViewTabs = [
    'suborgs',
    'team',
    'groups',
    'people',
    'surveys',
    'labels',
];
angular
    .module('missionhubApp')
    .constant('ministryViewTabs', ministryViewTabs)
    .constant('ministryViewDefaultTab', ministryViewTabs[0]);
