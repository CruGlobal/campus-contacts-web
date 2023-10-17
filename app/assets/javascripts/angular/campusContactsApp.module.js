import angular from 'angular';
import ngAnimate from 'angular-animate';
import uiRouter from '@uirouter/angularjs';
import '@uirouter/angularjs/lib/legacy/resolveService';
import uiSelect from 'ui-select';
import 'ui-select/src/common.css';
import ngMdIcons from 'angular-material-icons';
import 'jsonapi-datastore/dist/ng-jsonapi-datastore';
import ngEnvironment from 'angular-environment';
import 'angular-legacy-sortablejs-maintained';
import uiBootstrap from 'angular-ui-bootstrap';
import ngScrollGlue from 'angularjs-scroll-glue';
import angulartics from 'angulartics';
import angularticsGoogle from 'angulartics-google-analytics';
import ngFileUpload from 'ng-file-upload';
import ngInfiniteScroll from 'ng-infinite-scroll';
import 'angularjs-toaster';
import 'angularjs-toaster/toaster.scss';
import 'moment';
import 'angular-smart-table';

export default angular.module('campusContactsApp', [
  ngAnimate,
  ngMdIcons,
  'beauby.jsonApiDataStore',
  ngEnvironment,
  uiRouter,
  uiSelect,
  'ng-sortable',
  uiBootstrap,
  ngFileUpload,
  ngInfiniteScroll,
  'toaster',
  ngScrollGlue,
  angulartics,
  angularticsGoogle,
  'smart-table',
]);
