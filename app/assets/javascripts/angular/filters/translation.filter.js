import i18next from 'i18next';

angular.module('campusContactsApp').filter('t', function () {
    function translateFilter(key, options) {
        return i18next.t(key, options);
    }
    translateFilter.$stateful = true;
    return translateFilter;
});
