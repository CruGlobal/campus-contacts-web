import i18n from 'i18next';
import mapValues from 'lodash/mapValues';
import { initReactI18next } from 'react-i18next';

import translations from './locales/translations.json';
import en_US from './locales/en-US';

export default i18n.use(initReactI18next).init({
    fallbackLng: 'en-US',

    // Use downloaded translations if available but use en-US from source to make development easier
    resources: {
        ...mapValues(translations, 'translation'),
        ...{ 'en-US': en_US },
    },

    // have a common namespace used around the full app
    ns: ['common'],
    defaultNS: 'common',
    fallbackNS: 'common',

    interpolation: {
        escapeValue: false, // AngularJS seems to escape the value again, resulting in HTML Character Entities being printed. React didn't need this.
    },
    react: {
        wait: true,
        nsMode: 'fallback',
    },
});
