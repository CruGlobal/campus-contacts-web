import 'regenerator-runtime/runtime';

import { resetGlobalMockSeeds } from './dashboard/testUtils/globalMocks';
import './i18n/i18next.config';

jest.mock('./dashboard/apolloClient', () => ({
    apolloClient: require('./dashboard/testUtils/apolloMockClient').createApolloMockClient(),
}));

beforeEach(() => {
    resetGlobalMockSeeds();
});
