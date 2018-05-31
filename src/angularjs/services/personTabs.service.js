var personTabs = ['profile', 'history', 'assigned', 'activity'];
angular.module('missionhubApp')
    .constant('personTabs', personTabs)
    .constant('personDefaultTab', personTabs[0]);
