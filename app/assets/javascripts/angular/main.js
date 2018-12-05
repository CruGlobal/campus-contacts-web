/* eslint-disable angular/window-service */
if (window.__webpack_public_path__) {
    __webpack_public_path__ = window.__webpack_public_path__;
}

import '../../../../src/i18n/i18next.config';

import './missionhubApp.module';
import './missionhubApp.constants';
import './missionhubApp.config';
import './rollbar.config';
import './missionhubApp.routes';
import './missionhubApp.run';

import '../../../../src/app.component';
import '../../../../src/components/authentication/login.component';

import '../../stylesheets/main.scss';

/* global require */
const srcFilesContext = require.context(
    './',
    true,
    /^(?!.*\.spec\.js$).*\.js$/,
);
srcFilesContext.keys().forEach(srcFilesContext);
