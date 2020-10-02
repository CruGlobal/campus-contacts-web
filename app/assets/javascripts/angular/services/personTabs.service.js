var personTabs = ['profile', 'history', 'assigned', 'activity'];
angular
    .module('campusContactsApp')
    .constant('personTabs', personTabs)
    .constant('personDefaultTab', personTabs[0]);
