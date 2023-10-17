import template from './reportPeriod.html';
import './reportPeriod.scss';

angular.module('campusContactsApp').component('reportPeriod', {
  controller: reportPeriodController,
  template,
});

function reportPeriodController(periodService) {
  const vm = this;
  vm.periods = periodService.getPeriods();
  vm.getPeriod = periodService.getPeriod;
  vm.setPeriod = periodService.setPeriod;
}
