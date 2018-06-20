import './missionhubApp.module';
import './missionhubApp.constants';
import './missionhubApp.config';
import './rollbar.config';
import './missionhubApp.routes';
import './missionhubApp.run';

import '../../stylesheets/bootstrap.scss';
import '../../stylesheets/pivot_theme.scss';

/* global require */
const srcFilesContext = require.context(
    './',
    true,
    /^(?!.*\.spec\.js$).*\.js$/,
);
srcFilesContext.keys().forEach(srcFilesContext);
