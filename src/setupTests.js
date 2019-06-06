import 'babel-polyfill';

jest.mock('./dashboard/apolloClient', () => ({
    apolloClient: require('./dashboard/testUtils/apolloMockClient').createApolloMockClient(),
}));
