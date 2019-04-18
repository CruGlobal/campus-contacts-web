import ApolloClient from 'apollo-client';
import { InMemoryCache } from 'apollo-cache-inmemory';
import { ApolloLink } from 'apollo-link';
import { withClientState } from 'apollo-link-state';
import defaults from './defaults';
import resolvers from '../resolvers';
import { createHttpLink } from 'apollo-link-http';

// Define a new httpLink to connect to our GraphQL Endpoint
const httplink = createHttpLink({
    uri: 'https://api-stage.missionhub.com/apis/graphql',
});

const cache = new InMemoryCache();
const stateLink = withClientState({
    cache,
    defaults,
    resolvers,
});

export const client = new ApolloClient({
    cache,
    link: ApolloLink.from([stateLink, httplink]),
});
