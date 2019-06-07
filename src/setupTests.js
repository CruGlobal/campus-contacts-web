import 'regenerator-runtime/runtime';

jest.mock('./dashboard/apolloClient', () => ({
    apolloClient: require('./dashboard/testUtils/apolloMockClient').createApolloMockClient(),
}));
