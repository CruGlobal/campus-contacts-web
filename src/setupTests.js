import 'regenerator-runtime/runtime';
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';

import { resetGlobalMockSeeds } from './dashboard/testUtils/globalMocks';
import './i18n/i18next.config';

i18n.use(initReactI18next).init({
    react: {
        wait: true,
        nsMode: 'fallback',
    },
});

jest.mock('./dashboard/apolloClient', () => ({
    apolloClient: require('./dashboard/testUtils/apolloMockClient').createApolloMockClient(),
}));

beforeEach(() => {
    resetGlobalMockSeeds();
});
