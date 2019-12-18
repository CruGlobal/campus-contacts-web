import './workboxServiceWorker';

import '../../../../src/i18n/i18next.config';

import './missionhubApp.module';
import './missionhubApp.constants';
import './missionhubApp.config';
import './rollbar.config';
import './missionhubApp.routes';
import './missionhubApp.run';

import '../../../app.component';
import '../../../components/authentication/signIn.component';
import '../../../components/authentication/inviteLink.component';
import '../../../components/authentication/mergeAccount.component';
import '../../../components/authentication/impersonateUser.component';
import '../../../components/authentication/authLanding.component';

import '../../../../src/communityInsights/insights';
import '../../../../src/graphqlPlayground/GraphqlPlaygroundLazy';

import '../../stylesheets/main.scss';

/* global require */
const srcFilesContext = require.context(
    './',
    true,
    /^(?!.*\.spec\.js$).*\.js$/,
);
srcFilesContext.keys().forEach(srcFilesContext);
