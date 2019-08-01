import { createHttpLink } from 'apollo-link-http';
import { InMemoryCache } from 'apollo-cache-inmemory';
import { withClientState } from 'apollo-link-state';
import ApolloClient from 'apollo-client';
import { ApolloLink } from 'apollo-link';

import defaults from './state/defaults';
import resolvers from './resolvers';

const cache = new InMemoryCache();
const stateLink = withClientState({
    cache,
    defaults,
    resolvers,
});

export const createApolloClient = token => {
    const httplink = createHttpLink({
        uri: 'https://api-stage.missionhub.com/apis/graphql',
        includeExtensions: true,
        headers: {
            Authorization: `Bearer ${token}`,
        },
    });

    console.log(token);
    return new ApolloClient({
        cache,
        link: ApolloLink.from([stateLink, httplink]),
    });
};
