import 'regenerator-runtime/runtime';
import { resetGlobalMockSeeds } from './dashboard/testUtils/globalMocks';

jest.mock('./dashboard/apolloClient', () => ({
    apolloClient: require('./dashboard/testUtils/apolloMockClient').createApolloMockClient(),
}));

beforeEach(() => {
    resetGlobalMockSeeds();
});
