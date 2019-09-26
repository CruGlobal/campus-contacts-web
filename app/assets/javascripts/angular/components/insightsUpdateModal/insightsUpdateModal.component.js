import template from './insightsUpdateModal.html';

import './insightsUpdateModal.scss';

angular.module('missionhubApp').component('insightsUpdateModal', {
    template: template,
    bindings: {
        resolve: '<',
        close: '&',
        dismiss: '&',
    },
});
