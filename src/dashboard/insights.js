// Vendors
import React from 'react';
import PropTypes from 'prop-types';
import { ApolloProvider } from 'react-apollo-hooks';
import { react2angular } from 'react2angular';
import { ThemeProvider } from 'emotion-theming';
import ApolloClient from 'apollo-client';
import { InMemoryCache } from 'apollo-cache-inmemory';
import { ApolloLink } from 'apollo-link';
import { withClientState } from 'apollo-link-state';
import { createHttpLink } from 'apollo-link-http';
// Project specific
import defaults from './state/defaults';
import resolvers from './resolvers/index';
// Components
import Navigation from './components/navigation';

const theme = {
    colors: {
        light: '#A3A9AF',
    },
};

const Insights = ({ orgId, authenticationService }) => {
    // Utilize authenticationService to grab jwt Token for headers auth
    const token = authenticationService.isTokenValid();
    // Initialize a new httpLink to our api
    const httplink = createHttpLink({
        uri: 'https://api-stage.missionhub.com/apis/graphql',
        includeExtensions: true,
        headers: {
            Authorization: `Bearer ${token}`,
        },
    });

    const cache = new InMemoryCache();
    const stateLink = withClientState({
        cache,
        defaults,
        resolvers,
    });

    const client = new ApolloClient({
        cache,
        link: ApolloLink.from([stateLink, httplink]),
    });

    return (
        <ApolloProvider client={client}>
            <ThemeProvider theme={theme}>
                <Navigation orgId={orgId} />
            </ThemeProvider>
        </ApolloProvider>
    );
};

Insights.propTypes = {
    orgId: PropTypes.string,
    theme: PropTypes.object,
    token: PropTypes.string,
};

angular
    .module('missionhubApp')
    .component(
        'insights',
        react2angular(Insights, ['orgId'], ['authenticationService']),
    );

export { Insights };
