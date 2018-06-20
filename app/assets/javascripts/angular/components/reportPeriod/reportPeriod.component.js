import template from './reportPeriod.html';
import './reportPeriod.scss';

angular.module('missionhubApp').component('reportPeriod', {
    controller: reportPeriodController,
    template: template,
});

function reportPeriodController(periodService) {
    var vm = this;
    vm.periods = periodService.getPeriods();
    vm.getPeriod = periodService.getPeriod;
    vm.setPeriod = periodService.setPeriod;
}
