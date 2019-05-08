import '../../../../src/i18n/i18next.config';

import './missionhubApp.module';
import './missionhubApp.constants';
import './missionhubApp.config';
import './rollbar.config';
import './missionhubApp.routes';
import './missionhubApp.run';

import '../../../../src/app.component';
import '../../../../src/components/authentication/signIn.component';
import '../../../../src/components/authentication/inviteLink.component';
import '../../../../src/components/authentication/mergeAccount.component';
import '../../../../src/components/authentication/impersonateUser.component';
import '../../../../src/components/authentication/authLanding.component';

import '../../stylesheets/main.scss';

/* global require */
const srcFilesContext = require.context(
    './',
    true,
    /^(?!.*\.spec\.js$).*\.js$/,
);
srcFilesContext.keys().forEach(srcFilesContext);
