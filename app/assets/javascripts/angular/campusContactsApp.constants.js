import _ from 'lodash';
import moment from 'moment';

angular
  .module('campusContactsApp')
  .constant('_', _)
  .constant('moment', moment)
  .constant('p2cOrgId', '8411')
  .constant('rollbarAccessToken', 'e749b290a241465b9e70c9cf93124721');
