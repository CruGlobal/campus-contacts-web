import './workboxServiceWorker';

import '../../../../src/i18n/i18next.config';

import './campusContactsApp.module';
import './campusContactsApp.constants';
import './campusContactsApp.config';
import './rollbar.config';
import './campusContactsApp.routes';
import './campusContactsApp.run';

import '../../../app.component';
import '../../../components/authentication/signIn.component';
import '../../../components/authentication/inviteLink.component';
import '../../../components/authentication/mergeAccount.component';
import '../../../components/authentication/impersonateUser.component';
import '../../../components/authentication/authLanding.component';

import '../../stylesheets/main.scss';

/* global require */
const srcFilesContext = require.context('./', true, /^(?!.*\.spec\.js$).*\.js$/);
srcFilesContext.keys().forEach(srcFilesContext);
