import './missionhubApp.module';
import './missionhubApp.constants';
import './missionhubApp.config';
import './rollbar.config';
import './missionhubApp.routes';
import './missionhubApp.run';

/* global require */
const srcFilesContext = require.context('./', true, /^(?!.*\.spec\.js$).*\.js$/);
srcFilesContext.keys().forEach(srcFilesContext);
